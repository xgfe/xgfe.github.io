title: iOS源码解读-对象关联实现分析 
date: 2018-03-24 20:31:49 
categories: lixiaoqiang 
tags: 
- iOS 
- Catogery
---
本文主要分析iOS对象关联的实现。
<!-- more -->
### 疑问  
在iOS开发中，经常为了将代码解耦或者在原有的类的基础上扩展功能，经常会使用类目(Catogery)。但是大家都知道分类添加的属性Xcode不会自动的为其生成一个下划线开头的成员变量及set和get方法，如果你没有手动实现这两个方法，直接在外面通过点语法调用这个属性，肯定就挂了，会报“unrecognized selector sent to instance”的错误。假设我们在类目.h中放置一个属性（但是并不声明set方法和get方法），我们在类目中.m中尝试添加自定义set方法和get方法，我们发现已经可以像正常类一样调用这个类目的属性，这里就说明了@property已经帮我们申明了set和get方法，只是并没有实现。这样我们自己实现了set和get方法，但是没有成员变量来存放我们set的值，这样get的时候也就无法取到set的值，这样肯定是不行的。那我们猜想一下苹果会怎么设计这个set的值存储的方式。

### 猜想
在没有看到苹果的实现之前，我想的是将set的值存放在一个单例下的变量中，这样在get的时候去取这个单例中被set的变量。但是这会产生一个问题，那就是如果我们在一个工程中创建了很多类目，事实上，在开发的过程中类目文件很多也是很正常的。那么我们可能需要创建单例来保存这些类目下的属性，也许会用一个全局的单例，或者是每个类目创建一个单例来存储。这是我的想法，那我们看看苹果的做法究竟是什么。

### 苹果的做法
通过查阅资料，我们看到给category的做法是利用了“_object_set_associative_reference(id object, void *key, id value, uintptr_t policy)”这个方法，这个方法是将要添加的属性和类目扩展的对象关联起来，方法的第一个参数Object是需要关联的对象，key是一个常量，value是需要添加的属性。  
policy对应的是枚举表示关联引用的存储策略。
```objc
typedef OBJC_ENUM(uintptr_t, objc_AssociationPolicy) {
    OBJC_ASSOCIATION_ASSIGN = 0,           /**< Specifies a weak reference to the associated object. */
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1, /**< Specifies a strong reference to the associated object. 
                                            *   The association is not made atomically. */
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3,   /**< Specifies that the associated object is copied. 
                                            *   The association is not made atomically. */
    OBJC_ASSOCIATION_RETAIN = 01401,       /**< Specifies a strong reference to the associated object.
                                            *   The association is made atomically. */
    OBJC_ASSOCIATION_COPY = 01403          /**< Specifies that the associated object is copied.
                                            *   The association is made atomically. */
};
```
接下来我们来看这个“_object_set_associative_reference”的方法的具体实现，虽然是c++的代码，我们只要认真的沉下心来分析，还是能分析出苹果这个方法的实现思路。方法所做的事情我在代码中用中文注释出来。

```objc
void _object_set_associative_reference(id object, void *key, id value, uintptr_t policy) {
    // retain the new value (if any) outside the lock.
    ObjcAssociation old_association(0, nil); //构造了一个表示旧值的对象
    id new_value = value ? acquireValue(value, policy) : nil;//根据传进来的值和策略产生一个新值
    {
        AssociationsManager manager;//这是管理关联的单例
        AssociationsHashMap &associations(manager.associations());//这个单例里面有一个hashmap
        disguised_ptr_t disguised_object = DISGUISE(object);//DISGUISE是一个将对象指针转变的宏，这里暂且将disguised_object看做是传进来的对象经过转换产生的一个新对象
        if (new_value) {//如果这个传进来的值存在
            // break any existing association.
            AssociationsHashMap::iterator i = associations.find(disguised_object);//遍历单例中hashmap根据disguised_object 去找AssociationsHashMap类型的hashmap。由此可见，associations中存储着以disguised_object为key的多个hashmap
            if (i != associations.end()) {//表示找到了以传进来的以disguised_object为key的hashmap，下面就是在找到的hashmap中找以传进来的key为key的键值对.
                // secondary table exists
                ObjectAssociationMap *refs = i->second;
                ObjectAssociationMap::iterator j = refs->find(key);
                if (j != refs->end()) {//找到了跟传进来的key相同的键值对，将原来的键值得值赋值给刚开始初始化的old_association，然后将新值赋值给原来的键值对。
                    old_association = j->second;
                    j->second = ObjcAssociation(policy, new_value);
                } else {//如果没有找到相同的key，则直接关联到遍历得到的hashmap上
                    (*refs)[key] = ObjcAssociation(policy, new_value);
                }
            } else {//如果找不到以disguised_object为key的hashmap，则创建新的hashmap给大的associations
                // create the new association (first time).
                ObjectAssociationMap *refs = new ObjectAssociationMap;
                associations[disguised_object] = refs;
                (*refs)[key] = ObjcAssociation(policy, new_value);
                object->setHasAssociatedObjects();
            }
        } else {//如果新值不存在，则会根据传进来的key抹去原来的在hashmap中的以key对应的键值对
            // setting the association to nil breaks the association.
            AssociationsHashMap::iterator i = associations.find(disguised_object);
            if (i !=  associations.end()) {
                ObjectAssociationMap *refs = i->second;
                ObjectAssociationMap::iterator j = refs->find(key);
                if (j != refs->end()) {
                    old_association = j->second;
                    refs->erase(j);
                }
            }
        }
    }
    // release the old value (outside of the lock).
    if (old_association.hasValue()) ReleaseValue()(old_association)//根据其原本绑定的策略，对删掉的值做一些善后处理
}

```
经过源码分析我们知道了苹果是怎么关联的属性的底层的实现，那么要取出来存进去的属性那就简单了，就是根据key和object对象进行遍历，我们看看objc_getAssociatedObject(id _Nonnull object, const void * _Nonnull key)的底层实现:  
```objc
id _object_get_associative_reference(id object, void *key) {
    id value = nil;
    uintptr_t policy = OBJC_ASSOCIATION_ASSIGN;
    {
        AssociationsManager manager;
        AssociationsHashMap &associations(manager.associations());
        disguised_ptr_t disguised_object = DISGUISE(object);
        AssociationsHashMap::iterator i = associations.find(disguised_object);
        if (i != associations.end()) {
            ObjectAssociationMap *refs = i->second;
            ObjectAssociationMap::iterator j = refs->find(key);
            if (j != refs->end()) {
                ObjcAssociation &entry = j->second;
                value = entry.value();
                policy = entry.policy();
                if (policy & OBJC_ASSOCIATION_GETTER_RETAIN) {
                    objc_retain(value);
                }
            }
        }
    }
    if (value && (policy & OBJC_ASSOCIATION_GETTER_AUTORELEASE)) {
        objc_autorelease(value);
    }
    return value;
}

```  
果不其然，苹果也是按照我们的猜想去做的这件事。  

### 总结

根据我们的猜想然后去分析苹果的源码，发现苹果为分类的属性建造了一个大的hashmap，这个大的hashmap的里面又根据对象划分了多个子hashmap，划分的依照object来划分。每个子hashmap中存放了各个分类添加的属性。注意：每个分类的属性使用对象关联去关联属性的时候千万要保证key值得唯一性，否则会出现后面的存储覆盖掉前面的存储的情况。
