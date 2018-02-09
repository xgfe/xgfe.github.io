title: ListView源码分析
date: 2018-02-09 13:12
categories:
- caominkang
tags:
- android
- 源码
- listview

---

本文主要是分析ListView源码，重点关注复用机制。

<!--more-->

# ListView源码解析

&nbsp;&nbsp;本文分为三个部分，第一个部分提取出RecycleBin的相关代码，对RecyleBin做基本讲解；第二部分讲解ListView初始化时onLayout过程；第三部分讲解ListView如何在屏幕滑动中实现复用。



## 一、RecycleBin
&nbsp;&nbsp;RecycleBin是AbsListView的子类，也就是说只要是继承自AbsListView的，都可以使用这个机制，代码结构大概如下：
    
    class RecycleBin{
        private int mFirstPosition;
        private View[] mActiveViews = new View[0];
        private int mViewTypeCount;
        private ArrayList<View>[] mScrapViews;
        private ArrayList<View> mCurrentScrap;
        void fillActiveViews(int childCount,int firstActivePostion)
        void getActiveView(int position);
        void addScrapView(View scrap);
        View getSrapView(int position);
        public void setViewTypeCount(int viewTypeCount);
    }
    
下面介绍字段和api：

* mFirstPosition指的是mActiveView[0]中存储的View在数据中的position。
* mActiveViews缓存的是第一屏的数据，后面的讲解中会说明，主要是在ListView初始化中起作用
* mViewTypeCount代表数据种类，值由setViewTypeCount方法设置。ListView可以处理不同种类的数据
* mScrapViews用来缓存移出到屏幕外的view，因为ListView支持不同种类数据，所以mScrapViews是一个二维数组，对应不同种类数据，使用不同的ArrayList去缓存。
* fillActiveViews是将屏幕上可以看到的view缓存到mActiveViews中
* getActiveViews将指定的位置的view从mActiveViews中取出来，需要注意的是，取出后再次获取该位置view会返回空。
* getScrapView用于从mScrapView中取出view，由于同种数据类型的view都是相同的，所以该方法只是返回该类型最后一个位置的view。

也就是说RecycleBin有两种缓存view的模式：ActiveView和ScrapView.ListView在初始化过程中使用mActiveViews来缓存显示在屏幕中的view，在滚动过程中使用mScrapView缓存移除到屏幕外的数据，实现复用。下面我来具体看ListView是如何通过调用RecycleBin的方法来管理view的复用。



## 二、ListView初始化过程
&nbsp;&nbsp;重点关注ListView初始化过程中onLayout过程，因为与RecycleBin交互主要在这个过程。我们知道，android视图树的根节点是FrameLayout子类，而FrameLayout会让子view执行两次onLayout过程，ListView也不例外，也会有两次onLayout过程。
### 1.第一次onLayout
&nbsp;&nbsp;ListView中没有复写父类AbsListView的onLayout方法，不过在父类onLayout中，做完数据判断后，直接调用了layoutChildren，并且注释有说明，子类不应该复写onLayout方法，而该复写layoutChildren。由于layoutChildren需要针对两次onLayout处理，所以判断和分支流程特别复杂，抽取出第一次调用的流程，大概如下：
    
     protected void layoutChildren(){
        int childCount = getChildCount();
        
        switch(mLayoutMode){
        
        }
        boolean dataChanged = mDataChanged;
        if(dataChanged){
        
        }else{
            recycleBin.fillActiveView(childCount,firstPosition);
        }
        detachAllViewsFromParent();
        switch (mLayoutMode){
            default:
                if(childCount==0)
                    fillFromTop(childrenTop);
                else
                    fillSpecific(0,childrenTop)

        }

    }

&nbsp;&nbsp;以上是代码结构，省去了很多与分析流程无关的代码，可以看到，由于我们数据源没有变化，dataChanged等于false，进入fillActiveViews，但是此时ListView没有任何子view，childCount为0，这行代码没有任何作用，进入switch语句后，进入default分支，调用fillFromTop。我们进入该函数，发现主要调用了fillDown方法，完整代码如下

    private View fillDown(int pos, int nextTop) {
        View selectedView = null;
        int end = (getBottom() - getTop()) - mListPadding.bottom;
        while (nextTop < end && pos < mItemCount) {
            // is this the selected item?  
            boolean selected = pos == mSelectedPosition;
            View child = makeAndAddView(pos, nextTop, true, mListPadding.left, selected);
            nextTop = child.getBottom() + mDividerHeight;
            if (selected) {
                selectedView = child;
            }
            pos++;
        }
        return selectedView;
    }

&nbsp;&nbsp;可以看到，循环调用makeAndAddView（）方法，终止条件是数据项加载完或者最后一个子view的top小于ListView的底部。实现从ListView顶部一直填充到ListView底部，那么makeAndAddView方法肯定是构建view并且填充view到ListView中，下面是相关代码：
    
     private View makeAndAddView(int position, int y, boolean flow, int childrenLeft,
                                boolean selected) {
        View child;
        if (!mDataChanged) {
            // Try to use an exsiting view for this position
            child = mRecycler.getActiveView(position);
            if (child != null) {
                // Found it -- we're using an existing child
                // This just needs to be positioned
                setupChild(child, position, y, flow, childrenLeft, selected, true);
                return child;
            }
        }
        // Make a new view for this position, or convert an unused view if possible
        child = obtainView(position, mIsScrap);
        // This needs to be positioned and measured
        setupChild(child, position, y, flow, childrenLeft, selected, mIsScrap[0]);
        return child;
    }

&nbsp;&nbsp;首先尝试通过recycler的getActiveView获取view，由于没有缓存过任何view，这里是获取不到的，再使用obtainView获取view。代码如下

    View obtainView(int position, boolean[] isScrap) {
        isScrap[0] = false;
        View scrapView;
        scrapView = mRecycler.getScrapView(position);
        View child;
        if (scrapView != null) {
            child = mAdapter.getView(position, scrapView, this);
            if (child != scrapView) {
                mRecycler.addScrapView(scrapView);
                if (mCacheColorHint != 0) {
                    child.setDrawingCacheBackgroundColor(mCacheColorHint);
                }
            } else {
                isScrap[0] = true;
                dispatchFinishTemporaryDetach(child);
            }
        } else {
            child = mAdapter.getView(position, null, this);
            if (mCacheColorHint != 0) {
                child.setDrawingCacheBackgroundColor(mCacheColorHint);
            }
        }
        return child;
    }
    
&nbsp;&nbsp;首先尝试从recyclerBin中获取scrapView，获取成功后作为参数传入Adapter.getView方法中，若获取失败，则将null传入Adapter.getView方法中。我们知道，在使用ListView时需要自定义Adapter，会复写getView方法，通常如下：
    
     public View getView(int position, @Nullable View convertView, @NonNull ViewGroup parent) {
        Fruit fruit = getItem(position);
        View view;
        ViewHolder viewHolder;
        if (convertView == null) {
            view = LayoutInflater.from(getContext()).inflate(resourceId, parent, false);
            viewHolder = new ViewHolder();
            viewHolder.fruitImage = view.findViewById(R.id.fruit_image);
            viewHolder.fruitName = view.findViewById(R.id.fruit_name);
            view.setTag(viewHolder);
 
        } else {
            view = convertView;
            viewHolder = (ViewHolder) view.getTag();
        }
        viewHolder.fruitImage.setImageResource(fruit.getImageId());
        viewHolder.fruitName.setText(fruit.getName());
        if(position==0)
            view.setBackgroundColor(Color.RED);

        return view;

    }

&nbsp;&nbsp;我们可以看到，convertView为空时会使用LayoutInflater加载布局，如果不为空的话，直接复用convertView。到这里obtainView逻辑已经清楚了，回到makeAndAddView中，会将obtainView得到的view传入到setUpChild方法中，然后会调用addViewInLayout将该view添加到ListView中。也就是说第一次onLayout 方法使用Inflater加载了刚好一屏幕数据，其他数据并没有加载。
###2.第二次onLayout
&nbsp;&nbsp;我们依然从layoutChild方法开始，代码结构如下：
    
    protected void layoutChildren(){
        int childCount = getChildCount();
        
        switch(mLayoutMode){
        
        }
        boolean dataChanged = mDataChanged;
        if(dataChanged){
        
        }else{
            recycleBin.fillActiveView(childCount,firstPosition);
        }
        detachAllViewsFromParent();
        switch (mLayoutMode){
            default:
                if(childCount==0)
                    fillFromTop(childrenTop);
                else
                    fillSpecific(0,childrenTop)

        }

    }

&nbsp;&nbsp;这次我们可以看到由于childCount已经不是0，代码流程如下：

* recycleBin.fillActiveView():将屏幕中的view缓存到ActiveView[]中
* detachAllViewsFromParent():将第一次onLayout加入到ListView中的所有view从ListView中detach
* fillSpecific（0，childrenTop）将view加载到ListView中

&nbsp;&nbsp;fillSpecific是第一次onLayout过程中没有用到的方法，这个方法逻辑和fillDown很相似，不过是先加载指定位置view再分别加载两边view，由于传入的position是0，效果上基本和fillDown一样。所有我们还是关注makeAndAddView:
    
     private View makeAndAddView(int position, int y, boolean flow, int childrenLeft,
                                boolean selected) {
        View child;
        if (!mDataChanged) {
            // Try to use an exsiting view for this position
            child = mRecycler.getActiveView(position);
            if (child != null) {
                // Found it -- we're using an existing child
                // This just needs to be positioned
                setupChild(child, position, y, flow, childrenLeft, selected, true);
                return child;
            }
        }
        // Make a new view for this position, or convert an unused view if possible
        child = obtainView(position, mIsScrap);
        // This needs to be positioned and measured
        setupChild(child, position, y, flow, childrenLeft, selected, mIsScrap[0]);
        return child;
    }
    
&nbsp;&nbsp;这次代码逻辑就很简单了，mRecycler.getActiveView从缓存中获取view后直接将view传入setUpChild中，不过与第一次调用该方法不同的是，最后一个参数传入的是true，标记该view是使用的缓存，根据该标记，setUpChild方法内会走到attachViewToParent,将该view attach到ListView中。两次onLayout总体来说是这样的：

* 使用inflater加载第一屏数据
* 将第一屏数据加入到recycleBin的ActiveViews中，并将这些view从ListView中移除
* 将ActiveViews中的view取出，重新attach到ListView中

&nbsp;&nbsp;也就是说，在onLayout阶段，ActiveView主要是缓存第一次加载的数据，以避免因为两次onLayout产生重复数据

## 三、屏幕滑动
&nbsp;&nbsp;屏幕滑动的处理是写在AbsListView中，触摸监听函数是onTouchEvent（），该函数会针对不同类型的触摸事件进行处理，而在屏幕上滑动事件对应的是ACTION_MOVE,而该case又嵌套一个switch分支，针对TOUCH_MODE处理，我们直接看TOUCH_MODE_SRCOLL,对应手指在屏幕上滑动。在该case内，调用了trackMotionScroll方法，也就是说只要手指在屏幕上滑动，trackMotionScroll就会被调用，trackMotion中核心代码如下：
    
    final boolean down = incrementalDeltaY<0;
     if(down)
    {
        final int top = listPadding.top - incrementalDeltaY;
        for (int i = 0; i < childCount; i++) {
            final View child = getChildAt(i);
            if (child.getBottom() >= top) {
                break;
            } else {
                count++;
                int position = firstPosition + i;
                if (position >= headerViewsCount && position < footerViewsStart) {
                    mRecycler.addScrapView(child);
                }
            }
        }
    } else
    {
        final int bottom = getHeight() - listPadding.bottom - incrementalDeltaY;
        for (int i = childCount - 1; i >= 0; i--) {
            final View child = getChildAt(i);
            if (child.getTop() <= bottom) {
                break;
            } else {
                start = i;
                count++;
                int position = firstPosition + i;
                if (position >= headerViewsCount && position < footerViewsStart) {
                    mRecycler.addScrapView(child);
                }
            }
        }
    }

&nbsp;&nbsp;incrementalDeltaY是上次触发event事件时手指在y方向的改变量，如果小于0说明在屏幕上下滑，进入down为true流程。从ListView第一个child开始判断，只要该view的bottom小于ListView的top，说明该view已经划出了屏幕，调用mRecycler.addScrapView将该view缓存到scrapViews中,用count记录下缓存的数量。这样滑出屏幕的view已经缓存下来了，继续看接下来代码:
    
    if (count > 0) {
        detachViewsFromParent(start, count);
    }
    offsetChildrenTopAndBottom(incrementalDeltaY);  
    if (down) {
        mFirstPosition += count;
    }
    invalidate();
    final int absIncrementalDeltaY = Math.abs(incrementalDeltaY);  
    if (spaceAbove < absIncrementalDeltaY || spaceBelow < absIncrementalDeltaY) {
        fillGap(down);
    }
代码流程如下：

* 调用detachViewFromParent，将滑出屏幕的view从ListView中detach掉
* 调用offsetChildrenTopAndBottom按照便宜量平移剩下的子view，实现滑动效果
* 调用fillGap处理将要滑动到屏幕内的view

那我们看fillGap如何处理将要移入屏幕的子view的：
    
    void fillGap(boolean down) {
        final int count = getChildCount();
        if (down) {
            final int startOffset = count > 0 ? getChildAt(count - 1).getBottom() + mDividerHeight :
                    getListPaddingTop();
            fillDown(mFirstPosition + count, startOffset);
            correctTooHigh(getChildCount());
        } else {
            final int startOffset = count > 0 ? getChildAt(0).getTop() - mDividerHeight :
                    getHeight() - getListPaddingBottom();
            fillUp(mFirstPosition - 1, startOffset);
            correctTooLow(getChildCount());
        }
    }

&nbsp;&nbsp;我们可以看到，方法内部主要是调用了fillDown或者fillUp，我们来回顾下fillDown的逻辑

* 从activeView中获取缓存的view
* 若第一步获取不成功，则调用obtainView获取view
* obtainView会先尝试复用scrapView中的view
* 若上一步复用失败，则使用inflater加载布局来生成view
* 将得到的view传入setUpChild中以加入ListView中

&nbsp;&nbsp;也就是说，在滑动屏幕时，每当有view从屏幕中移出，就先缓存到scrapViews中，再从ListView中移除该view，而每当有view要滑入屏幕中时，会从scrapViews中取出缓存的view,将其中的数据更新为相应位置的数据，再加入到ListView中，这样的循环使得ListView无论加载多少数据，都是固定数量的view在循环利用，内存都不会增加。
## 四、总结
&nbsp;&nbsp;ListView通过activeView解决两次onLayout过程中数据重复问题，通过scrapView解决滑动过程中view复用问题。无论是onLayout过程还是滑动过程，都是采用attach-detach-attach的操作思路，将两个阶段统一为一个抽象操作，以实现代码的复用。








  
    
    

    
    

    
    

  
  
 
 
 
     
    





