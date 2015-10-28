title: git commit hook
date: 2015-10-28 00:00:00
categories: felix
tags: 
- git
- git hook
- 代码规范
---

xgfe团队已经定制了自己的html的编码规范，对应的html规范检查工具[xg-htmlhint](https://github.com/yangjiyuan/xg-htmlhint)。以后也会有对应的js, css, sass编码规范和检查工具诞生，但是规范的制定和执行是两码事儿，而且往往存在很大的不对等。虽然辅以强大的编辑器插件我们可以做到在文件保存时做规范检查和提醒，但这样一来可能会打断思路，再者多多少少可以被轻易绕过。所以本文介绍引入git commit hook，在本地Commit代码之前先进行代码规范检查，通过后才能进行Commit。
<!-- more -->

# Git Hook

Hook，又叫挂钩，在Git中被提供用来供开发人员在工作流中插入自定义脚本来一些进行相关的操作。在使用Git进行版本管理的项目中，在.git/hooks中可以看到这些文件，Git将他们改为了.sample的后缀以阻止其执行。在进行工作前，Git会先检查该工作流对应的是否挂钩存在，若存在则会先去执行挂钩上的脚本文件。在不同工作流中，Git要求hook脚本返回的值不同，有些地方需要hook脚本返回0才能继续进行工作，否则会中断该工作流，有些地方却不要求返回值，直接会继续进行工作流。因为Git是版本控制工具，存在客户端和服务端，在不同的端提供的hook也不同，下面分开进行简要介绍（由于hook比较多，在这里只介绍几个我们工作中可能使用到的，其他有兴趣的同学可以去官网看。Git hook地址：[http://git-scm.com/docs/githooks](http://git-scm.com/docs/githooks))。

## pre-commit

pre-commit这个挂钩被 'git-commit' 命令调用, 而且可以通过在命令中添加\--no-verify 参数来跳过。这个挂钩没有参数，在得到提交消息后开始提交(commit)前被调用。如果挂钩执行结果是非零，那么 'git-commit' 命令就会中止执行。这个挂钩就可以用来在本地代码提交前进行代码检查，符合则继续提交代码。

## pre-commit 示例代码

附上pre-commit代码一份：

```
#!/bin/sh
#
# An example hook script to verify what is about to be committed.
# Called by "git commit" with no arguments.  The hook should
# exit with non-zero status after issuing an appropriate message if
# it wants to stop the commit.
#
# To enable this hook, rename this file to "pre-commit".

if git rev-parse --verify HEAD >/dev/null 2>&1
then
        against=HEAD
else
        # Initial commit: diff against an empty tree object
        against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi

# If you want to allow non-ascii filenames set this variable to true.
allownonascii=$(git config hooks.allownonascii)

# Cross platform projects tend to avoid non-ascii filenames; prevent
# them from being added to the repository. We exploit the fact that the
# printable range starts at the space character and ends with tilde.
if [ "$allownonascii" != "true" ] &&
        # Note that the use of brackets around a tr range is ok here, (it's
        # even required, for portability to Solaris 10's /usr/bin/tr), since
        # the square bracket bytes happen to fall in the designated range.
        test "$(git diff --cached --name-only --diff-filter=A -z $against |
          LC_ALL=C tr -d '[ -~]\0')"
then
        echo "Error: Attempt to add a non-ascii file name."
        echo
        echo "This can cause problems if you want to work"
        echo "with people on other platforms."
        echo
        echo "To be portable it is advisable to rename the file ..."
        echo
        echo "If you know what you are doing you can disable this"
        echo "check using:"
        echo
        echo "  git config hooks.allownonascii true"
        echo
        exit 1
fi

## Common
EXIT_CODE=0
REPO=$(pwd)

#
# Checking trailing whitespaces and indent
#

git diff --cached --check --color=always
EXIT_STATUS=$?
if [[ $EXIT_STATUS -ne 0 ]]; then
    EXIT_CODE=$((${EXIT_CODE} + $EXIT_STATUS))
fi

#
# Begin htmlhint hook
#

HTMLHINT_BIN=htmlhint
for FILE in `git diff-index --name-only ${against} -- | egrep .*\.html$`; do

    if test -f ${REPO}/${FILE}; then
        ${HTMLHINT_BIN} ${REPO}/${FILE}
    else
        continue
    fi

    # could similarly wrap Rhino or Node...

    EXIT_CODE=$((${EXIT_CODE} + $?))
done
# End htmlhint hook


#
# Begin JsHint hook
# A pre-commit hook for git to lint JavaScript files with jshint
# @see https://github.com/jshint/jshint/
#

JSHINT_BIN=jshint
for FILE in `git diff-index --name-only ${against} -- | egrep .*\.js$`; do

    if test -f ${REPO}/${FILE}; then
        ${JSHINT_BIN} ${REPO}/${FILE}
    else
        continue
    fi

    # could similarly wrap Rhino or Node...

    EXIT_CODE=$((${EXIT_CODE} + $?))
done
# End JsHint hook

#
# Begin CssLint hook
#
CSSLINT_BIN=csslint
for FILE in `git diff-index --name-only ${against} -- | egrep .*\.css$`; do

    if test -f ${REPO}/${FILE}; then
        ${CSSLINT_BIN} ${REPO}/${FILE}
    else
        continue
    fi


    # could similarly wrap Rhino or Node...

    EXIT_CODE=$((${EXIT_CODE} + $?))
done
# End CssLint hook

#
# Common
#

if [[ ${EXIT_CODE} -ne 0 ]]; then
    echo ""
    echo "Problems were found"
    echo "Commit aborted."
    exit ${EXIT_CODE}
fi
```

## 其他

当然除了git commit hook外，还有其它的许多hook，详见[http://git-scm.com/docs/githooks](http://git-scm.com/docs/githooks)，如git push hook还可以用来添加自动部署测试机的功能，剩下的就靠自己YY了。