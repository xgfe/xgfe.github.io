title: ListView源码分析
date: 2018-01-18 13:48
categories:
- caominkang
tags:
- android
- 源码
- listview

---

本文主要从源码角度分析listView的实现方式

<!--more-->

# ListView源码分析

listView作为列表控件，虽然已经被功能更加强大的recycleView取代，但是设计思想很适合android初学者学习，本文从listView的用法开始，通过源码讲解listView中复用机制


## 一、使用方法
本文侧重于原理讲解，使用方法不做过多讲解。重点说一下适配器部分，简单适配器代码如下：
    
    public class MyItemAdapter extends ArrayAdapter<Fruit> {
    private int resourceId;

    public MyItemAdapter(Context context, int textViewSourceId, List<Fruit> objects) {
        super(context, textViewSourceId, objects);
        resourceId = textViewSourceId;

    }


    @Override
    public View getView(int position, @Nullable View convertView, @NonNull ViewGroup parent) {
        Item item = getItem(position);
        View view;
        ViewHolder viewHolder;
        if (convertView == null) {
            view = LayoutInflater.from(getContext()).inflate(resourceId, parent, false);
            viewHolder = new ViewHolder();
            viewHolder.itemImage = view.findViewById(R.id.item_image);
            viewHolder.itemName = view.findViewById(R.id.item_name);
            view.setTag(viewHolder);
 
        } else {
            view = convertView;
            viewHolder = (ViewHolder) view.getTag();
        }
        viewHolder.itemImage.setImageResource(item.getItemId());
        viewHolder.itemName.setText(item.getName());
        return view;

    }

    class ViewHolder {
        ImageView itemImage;
        TextView itemName;
    }
    }

MyItemAdapter重写了getView()方法，这个方法主要在每个子项滑入屏幕时调用。这里需要注意的是convertView参数，这个参数是之前缓存的布局中取出来的view，从代码中可以看到，如果convertView为空，则需要使用LayoutInflater加载布局，如果convertView不为空，则可以直接复用，也是本文重点讲解的复用机制。另一方面，代码中使用ViewHolder这个内部类缓存控件实例，是为了减少调用findViewById的次数，提高性能，和listView的复用机制没有直接关系。

## 二、原理分析
### 1.RecycleBin机制
ListView继承自抽象类AbsListView，ListView的复用过程依靠AbsListView中的一个内部类，也就是RecycleBin，下面是不完整代码：
    
    /**
     * The RecycleBin facilitates reuse of views across layouts. The RecycleBin has two levels of
     * storage: ActiveViews and ScrapViews. ActiveViews are those views which were onscreen at the
     * start of a layout. By construction, they are displaying current information. At the end of
     * layout, all views in ActiveViews are demoted to ScrapViews. ScrapViews are old views that
     * could potentially be used by the adapter to avoid allocating views unnecessarily.
     *
     * @see android.widget.AbsListView#setRecyclerListener(android.widget.AbsListView.RecyclerListener)
     * @see android.widget.AbsListView.RecyclerListener
     */
    class RecycleBin {
        private RecyclerListener mRecyclerListener;

        /**
         * The position of the first view stored in mActiveViews.
         */
        private int mFirstActivePosition;

        /**
         * Views that were on screen at the start of layout. This array is populated at the start of
         * layout, and at the end of layout all view in mActiveViews are moved to mScrapViews.
         * Views in mActiveViews represent a contiguous range of Views, with position of the first
         * view store in mFirstActivePosition.
         */
        private View[] mActiveViews = new View[0];

        /**
         * Unsorted views that can be used by the adapter as a convert view.
         */
        private ArrayList<View>[] mScrapViews;

        private int mViewTypeCount;

        private ArrayList<View> mCurrentScrap;

        /**
         * Fill ActiveViews with all of the children of the AbsListView.
         *
         * @param childCount The minimum number of views mActiveViews should hold
         * @param firstActivePosition The position of the first view that will be stored in
         *        mActiveViews
         */
        void fillActiveViews(int childCount, int firstActivePosition) {
            if (mActiveViews.length < childCount) {
                mActiveViews = new View[childCount];
            }
            mFirstActivePosition = firstActivePosition;

            //noinspection MismatchedReadAndWriteOfArray
            final View[] activeViews = mActiveViews;
            for (int i = 0; i < childCount; i++) {
                View child = getChildAt(i);
                AbsListView.LayoutParams lp = (AbsListView.LayoutParams) child.getLayoutParams();
                // Don't put header or footer views into the scrap heap
                if (lp != null && lp.viewType != ITEM_VIEW_TYPE_HEADER_OR_FOOTER) {
                    // Note:  We do place AdapterView.ITEM_VIEW_TYPE_IGNORE in active views.
                    //        However, we will NOT place them into scrap views.
                    activeViews[i] = child;
                    // Remember the position so that setupChild() doesn't reset state.
                    lp.scrappedFromPosition = firstActivePosition + i;
                }
            }
        }

        /**
         * Get the view corresponding to the specified position. The view will be removed from
         * mActiveViews if it is found.
         *
         * @param position The position to look up in mActiveViews
         * @return The view if it is found, null otherwise
         */
        View getActiveView(int position) {
            int index = position - mFirstActivePosition;
            final View[] activeViews = mActiveViews;
            if (index >=0 && index < activeViews.length) {
                final View match = activeViews[index];
                activeViews[index] = null;
                return match;
            }
            return null;
        }
        /**
         * @return A view from the ScrapViews collection. These are unordered.
         */
        View getScrapView(int position) {
            final int whichScrap = mAdapter.getItemViewType(position);
            if (whichScrap < 0) {
                return null;
            }
            if (mViewTypeCount == 1) {
                return retrieveFromScrap(mCurrentScrap, position);
            } else if (whichScrap < mScrapViews.length) {
                return retrieveFromScrap(mScrapViews[whichScrap], position);
            }
            return null;
        }

        /**
         * Puts a view into the list of scrap views.
         * <p>
         * If the list data hasn't changed or the adapter has stable IDs, views
         * with transient state will be preserved for later retrieval.
         *
         * @param scrap The view to add
         * @param position The view's position within its parent
         */
        void addScrapView(View scrap, int position) {
            final AbsListView.LayoutParams lp = (AbsListView.LayoutParams) scrap.getLayoutParams();
            if (lp == null) {
                // Can't recycle, but we don't know anything about the view.
                // Ignore it completely.
                return;
            }

            lp.scrappedFromPosition = position;

            // Remove but don't scrap header or footer views, or views that
            // should otherwise not be recycled.
            final int viewType = lp.viewType;
            if (!shouldRecycleViewType(viewType)) {
                // Can't recycle. If it's not a header or footer, which have
                // special handling and should be ignored, then skip the scrap
                // heap and we'll fully detach the view later.
                if (viewType != ITEM_VIEW_TYPE_HEADER_OR_FOOTER) {
                    getSkippedScrap().add(scrap);
                }
                return;
            }

            scrap.dispatchStartTemporaryDetach();

            // The the accessibility state of the view may change while temporary
            // detached and we do not allow detached views to fire accessibility
            // events. So we are announcing that the subtree changed giving a chance
            // to clients holding on to a view in this subtree to refresh it.
            notifyViewAccessibilityStateChangedIfNeeded(
                    AccessibilityEvent.CONTENT_CHANGE_TYPE_SUBTREE);

            // Don't scrap views that have transient state.
            final boolean scrapHasTransientState = scrap.hasTransientState();
            if (scrapHasTransientState) {
                if (mAdapter != null && mAdapterHasStableIds) {
                    // If the adapter has stable IDs, we can reuse the view for
                    // the same data.
                    if (mTransientStateViewsById == null) {
                        mTransientStateViewsById = new LongSparseArray<>();
                    }
                    mTransientStateViewsById.put(lp.itemId, scrap);
                } else if (!mDataChanged) {
                    // If the data hasn't changed, we can reuse the views at
                    // their old positions.
                    if (mTransientStateViews == null) {
                        mTransientStateViews = new SparseArray<>();
                    }
                    mTransientStateViews.put(position, scrap);
                } else {
                    // Otherwise, we'll have to remove the view and start over.
                    clearScrapForRebind(scrap);
                    getSkippedScrap().add(scrap);
                }
            } else {
                clearScrapForRebind(scrap);
                if (mViewTypeCount == 1) {
                    mCurrentScrap.add(scrap);
                } else {
                    mScrapViews[viewType].add(scrap);
                }

                if (mRecyclerListener != null) {
                    mRecyclerListener.onMovedToScrapHeap(scrap);
                }
            }
        }
        
  首先我们来看注释，对这个类有个基本认识，RecycleBin有两种类型的存储方式，一种是ActiveViews,一种是ScrapViews。ActiveViews用于缓存屏幕上显示的view，一旦ActiveViews中的view滑出屏幕，该view就会从ActiveViews中移除，加入到ScrapViews中。不过这里有个值得注意的地方，RecycleBin中有ArrayList<View>[] mscrapViews，是一个二维的，其实原因很简单，使用listView可以处理不同种类的数据，数据种类数用viewTypeCount字段存储，不同种类的数据存在不同的ArrayList<View>中，对于只有一种类型的数据，使用的是mCurrentScrap。
  再来看方法：
  fillActiveViews会根据第一个参数选择缓存多少view到mActiveViews中，同时记下第一个view的位置。而getActiveViews方法则是从mActiveViews中取出view，取出后，就将该位置的view设置为null，也就是说下次取同样位置时会返回null。getScrapView从ScrapViews中取出相应位置的ScrapView，addScrapView先判断是否是应该回收的view，再将可以回收的view放入ScrapViews中，有了俩对操作，就可以很方便的实现view管理了，下面一节再讲解listView具体如何实现复用的。
### 2. onLayout过程
由于本文关注复用过程，而复用过程大多数是在onLayout过程中体现的，所以我们先看onLayout方法。
    
    /**
     * Subclasses should NOT override this method but
     *  {@link #layoutChildren()} instead.
     */
    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        super.onLayout(changed, l, t, r, b);

        mInLayout = true;

        final int childCount = getChildCount();
        if (changed) {
            for (int i = 0; i < childCount; i++) {
                getChildAt(i).forceLayout();
            }
            mRecycler.markChildrenDirty();
        }

        layoutChildren();

        mOverscrollMax = (b - t) / OVERSCROLL_LIMIT_DIVISOR;

        // TODO: Move somewhere sane. This doesn't belong in onLayout().
        if (mFastScroll != null) {
            mFastScroll.onItemCountChanged(getChildCount(), mItemCount);
        }
        mInLayout = false;
    }
AbsListView中onLayout方法注释写的很清楚，子类不要重写这个方法，子类应该重写layoutChildren();我们用ide打开layoutChildren()，会发现方法特别长，不过我们挑重点的看，第一个switch语句的注释让我们知道这是做准备工作，先跳过，接下来一段代码是处理childview的focus ability的，这里不是我们要讨论的地方，于是到了以下代码段：
    
    // Pull all children into the RecycleBin.
            // These views will be reused if possible
            final int firstPosition = mFirstPosition;
            final RecycleBin recycleBin = mRecycler;
            if (dataChanged) {
                for (int i = 0; i < childCount; i++) {
                    recycleBin.addScrapView(getChildAt(i), firstPosition+i);
                }
            } else {
                recycleBin.fillActiveViews(childCount, firstPosition);
            }

            // Clear out old views
            detachAllViewsFromParent();
            recycleBin.removeSkippedScrap();

            switch (mLayoutMode) {
            case LAYOUT_SET_SELECTION:
                if (newSel != null) {
                    sel = fillFromSelection(newSel.getTop(), childrenTop, childrenBottom);
                } else {
                    sel = fillFromMiddle(childrenTop, childrenBottom);
                }
                break;
            case LAYOUT_SYNC:
                sel = fillSpecific(mSyncPosition, mSpecificTop);
                break;
            case LAYOUT_FORCE_BOTTOM:
                sel = fillUp(mItemCount - 1, childrenBottom);
                adjustViewsUpOrDown();
                break;
            case LAYOUT_FORCE_TOP:
                mFirstPosition = 0;
                sel = fillFromTop(childrenTop);
                adjustViewsUpOrDown();
                break;
            case LAYOUT_SPECIFIC:
                final int selectedPosition = reconcileSelectedPosition();
                sel = fillSpecific(selectedPosition, mSpecificTop);
                /**
                 * When ListView is resized, FocusSelector requests an async selection for the
                 * previously focused item to make sure it is still visible. If the item is not
                 * selectable, it won't regain focus so instead we call FocusSelector
                 * to directly request focus on the view after it is visible.
                 */
                if (sel == null && mFocusSelector != null) {
                    final Runnable focusRunnable = mFocusSelector
                            .setupFocusIfValid(selectedPosition);
                    if (focusRunnable != null) {
                        post(focusRunnable);
                    }
                }
                break;
            case LAYOUT_MOVE_SELECTION:
                sel = moveSelection(oldSel, newSel, delta, childrenTop, childrenBottom);
                break;
            default:
                if (childCount == 0) {
                    if (!mStackFromBottom) {
                        final int position = lookForSelectablePosition(0, true);
                        setSelectedPositionInt(position);
                        sel = fillFromTop(childrenTop);
                    } else {
                        final int position = lookForSelectablePosition(mItemCount - 1, false);
                        setSelectedPositionInt(position);
                        sel = fillUp(mItemCount - 1, childrenBottom);
                    }
                } else {
                    if (mSelectedPosition >= 0 && mSelectedPosition < mItemCount) {
                        sel = fillSpecific(mSelectedPosition,
                                oldSel == null ? childrenTop : oldSel.getTop());
                    } else if (mFirstPosition < mItemCount) {
                        sel = fillSpecific(mFirstPosition,
                                oldFirst == null ? childrenTop : oldFirst.getTop());
                    } else {
                        sel = fillSpecific(0, childrenTop);
                    }
                }
                break;
            }

            // Flush any cached views that did not get reused above
            recycleBin.scrapActiveViews();

由于这个时候childCount为0，无论dataChanged是否为真，都不会有什么发生，直接来到switch模块，由于LAYOUT_MODE一般为LAYOUT_NORMAL,我们直接来到default的case，由于childCount为0，第一个if调用了fillFromTop方法，点开fillFromTop方法，方法尾部return了filldown方法，filldown方法如下：
    
    /**
     * Fills the list from pos down to the end of the list view.
     *
     * @param pos The first position to put in the list
     *
     * @param nextTop The location where the top of the item associated with pos
     *        should be drawn
     *
     * @return The view that is currently selected, if it happens to be in the
     *         range that we draw.
     */
    private View fillDown(int pos, int nextTop) {
        View selectedView = null;

        int end = (mBottom - mTop);
        if ((mGroupFlags & CLIP_TO_PADDING_MASK) == CLIP_TO_PADDING_MASK) {
            end -= mListPadding.bottom;
        }

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

        setVisibleRangeHint(mFirstPosition, mFirstPosition + getChildCount() - 1);
        return selectedView;
    }

从注释我们看到该方法是第一个position开始，从顶到底填满listView。代码也体现了这一点，nextTop是第一个view顶部距离listView顶部的距离（padding），也就是第一个view开始的地方，每次循环都将nextTop置于下一个view开始的地方，end是listView在在垂直方向的长度。我们可以看到，循环中有makeAndView这个方法，看名字可以推测是创建和添加view，代码如下:
    
      private View makeAndAddView(int position, int y, boolean flow, int childrenLeft,
            boolean selected) {
        if (!mDataChanged) {
            // Try to use an existing view for this position.
            final View activeView = mRecycler.getActiveView(position);
            if (activeView != null) {
                // Found it. We're reusing an existing child, so it just needs
                // to be positioned like a scrap view.
                setupChild(activeView, position, y, flow, childrenLeft, selected, true);
                return activeView;
            }
        }

        // Make a new view for this position, or convert an unused view if
        // possible.
        final View child = obtainView(position, mIsScrap);

        // This needs to be positioned and measured.
        setupChild(child, position, y, flow, childrenLeft, selected, mIsScrap[0]);

        return child;
    }
    
    
我们可以看到，第一步是使用RecycelerBin中的getActiveView方法，明显这里是拿不到的，就需要使用obtainView方法，setupChild是子view具体的构建过程，这里不展开讲述。obtainView()的代码如下：

    /** 
     * Get a view and have it show the data associated with the specified 
     * position. This is called when we have already discovered that the view is 
     * not available for reuse in the recycle bin. The only choices left are 
     * converting an old view or making a new one. 
     *  
     * @param position 
     *            The position to display 
     * @param isScrap 
     *            Array of at least 1 boolean, the first entry will become true 
     *            if the returned view was taken from the scrap heap, false if 
     *            otherwise. 
     *  
     * @return A view displaying the data associated with the specified position 
    */  
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
    

第一步从scrapViews中获取，这里也很明显获取不到，于是调用mAdater中的getView()方法，这里的mAdapter就是我们自己写的适配器，getView方法也是我们在一开始重写的方法。第二个参数就是convertView，传入的是null，也就是说我们需要用LayoutInflater去加载布局。到这里我们发现，listView第一次只加载了刚好一个屏幕的数据，而且开始时的每一个view都是使用LayoutInflater加载的。看到这里，我们依然没有看到scrapViews和activeViews如何工作，不过我们在第二次onLayout时就可以看到了。为什么会有两次onLayout呢。原因是android中的控件显示到屏幕的过程中，会至少调用两次onLayout方法。在setContentView中，父容器是FrameLayout，这种情况下会调用子控件两次onLayout方法。那么我们进入第二次layout过程。第一次layout时，由于childCount为0，所以fillActiveViews没有什么作用，第二次layout时调用fillActiveViews会将屏幕内的views添加到mActiveViews中，跳过处理focused children这段代码，会看到detachAllViewsFromParent(),这个方法是删除listView里面的子view，这里是防止两次OnLayout展示两份相同数据。接下来的switch代码段我们直接跳到default，由于没有选中数据，所以mSelectedPosition=-1,而第一次mFirstPosition=0，这样会调用fillSpec方法，fillSpec方法会以传入position的view为基准，优先加载该view后再分别调用fillUp和fillDown，由于这里传入的position为0，所以效果和直接调用fillDown差不多，那么依然进入fillDown的makeAndAddView方法：
    
      /**
     * Obtains the view and adds it to our list of children. The view can be
     * made fresh, converted from an unused view, or used as is if it was in
     * the recycle bin.
     *
     * @param position logical position in the list
     * @param y top or bottom edge of the view to add
     * @param flow {@code true} to align top edge to y, {@code false} to align
     *             bottom edge to y
     * @param childrenLeft left edge where children should be positioned
     * @param selected {@code true} if the position is selected, {@code false}
     *                 otherwise
     * @return the view that was added
     */
    private View makeAndAddView(int position, int y, boolean flow, int childrenLeft,
            boolean selected) {
        if (!mDataChanged) {
            // Try to use an existing view for this position.
            final View activeView = mRecycler.getActiveView(position);
            if (activeView != null) {
                // Found it. We're reusing an existing child, so it just needs
                // to be positioned like a scrap view.
                setupChild(activeView, position, y, flow, childrenLeft, selected, true);
                return activeView;
            }
        }

        // Make a new view for this position, or convert an unused view if
        // possible.
        final View child = obtainView(position, mIsScrap);

        // This needs to be positioned and measured.
        setupChild(child, position, y, flow, childrenLeft, selected, mIsScrap[0]);

        return child;
    }

这里我们可以看到，是直接调用getActiveView方法从mActiveViews中获取第一次缓存的view，相应的会将setupChild的标志是否是回收的view会传入true，在方法里面就会调用attachViewToParent方法，将之前被detach的view attach到listView上。
### 3.滑动复用

通过前面讲解，我们发现，listView初始化时，只加载一屏幕数据，而且这个时候mActiveView中缓存的是这一屏幕view，mScrapView中暂时没有缓存。我们接下来看滑动过程。滑动涉及到事件，这个部分代码是写在父类中的onTouchEvent方法中，这个方法主要涉针对事件和动作做处理，手指滑动事件为MotionEvent.ACTION_MOVE，我们进入到这个case里面，发现里面嵌套的还是switch语句，用于处理TouchMode，在滑动过程中，TouchMode对应的是TOUCH_MODE_SCROLL,那么我们可以看到里面有调用trackMotionScroll方法，这个方法看似复杂，但是我们忽略掉与mGroupFlags和childAccessAbilityFocus部分代码后，重点看与位置有关部分。首先参数deltaY表示从手指按下时位置到当前手指位置距离，incrementalDeltaY表示上次出发event事件到现在手指在y方向的移动距离，incrementalDeltaY小于0，说明是下滑，这里需要注意，android的原点在左上角，y轴是从上到下，所以这里的下滑是针对坐标轴。方法一开始会做一些准备工作，比如将第一child的顶部位置和最后一个child的底部位置拿出来，做完这些工作后根据是滑动方向进去循环处理，代码如下
    
    if (down) {
            int top = -incrementalDeltaY;
            if ((mGroupFlags & CLIP_TO_PADDING_MASK) == CLIP_TO_PADDING_MASK) {
                top += listPadding.top;
            }
            for (int i = 0; i < childCount; i++) {
                final View child = getChildAt(i);
                if (child.getBottom() >= top) {
                    break;
                } else {
                    count++;
                    int position = firstPosition + i;
                    if (position >= headerViewsCount && position < footerViewsStart) {
                        // The view will be rebound to new data, clear any
                        // system-managed transient state.
                        child.clearAccessibilityFocus();
                        mRecycler.addScrapView(child, position);
                    }
                }
            }
        } else {
            int bottom = getHeight() - incrementalDeltaY;
            if ((mGroupFlags & CLIP_TO_PADDING_MASK) == CLIP_TO_PADDING_MASK) {
                bottom -= listPadding.bottom;
            }
            for (int i = childCount - 1; i >= 0; i--) {
                final View child = getChildAt(i);
                if (child.getTop() <= bottom) {
                    break;
                } else {
                    start = i;
                    count++;
                    int position = firstPosition + i;
                    if (position >= headerViewsCount && position < footerViewsStart) {
                        // The view will be rebound to new data, clear any
                        // system-managed transient state.
                        child.clearAccessibilityFocus();
                        mRecycler.addScrapView(child, position);
                    }
                }
            }
        }
        
可以看到，当下滑时，是通过判断子view的底部小于top值时，说明该view已经不在屏幕中了，会调用addScrapView方法将view添加到mScrapViews中，并用count记录有多少view不在屏幕中了。同理，上滑时是通过判断view顶部大于底部值，同样将该view添加到mScrapViews中。这个缓存步骤完成后，执行detach操作，将缓存的view从parent中移除，接着调用offsetChildrenTopAndBottom,是平移子view位置，在视觉上就有滑动的感觉。很显然平移过程中自然有屏幕外的数据滑到屏幕内，对应的方法是fillGap,当最后一个view的底部移入屏幕或者第一个view移出屏幕时调用，fillGap是抽象方法，回到ListView中，代码如下：
    
    void fillGap(boolean down) {
        final int count = getChildCount();
        if (down) {
            int paddingTop = 0;
            if ((mGroupFlags & CLIP_TO_PADDING_MASK) == CLIP_TO_PADDING_MASK) {
                paddingTop = getListPaddingTop();
            }
            final int startOffset = count > 0 ? getChildAt(count - 1).getBottom() + mDividerHeight :
                    paddingTop;
            fillDown(mFirstPosition + count, startOffset);
            correctTooHigh(getChildCount());
        } else {
            int paddingBottom = 0;
            if ((mGroupFlags & CLIP_TO_PADDING_MASK) == CLIP_TO_PADDING_MASK) {
                paddingBottom = getListPaddingBottom();
            }
            final int startOffset = count > 0 ? getChildAt(0).getTop() - mDividerHeight :
                    getHeight() - paddingBottom;
            fillUp(mFirstPosition - 1, startOffset);
            correctTooLow(getChildCount());
        }
    }
    
该方法主要是通过down来判断是调用fillDown还是调用fillUp，这两个方法都会再调用makeAndAddView来填充listView,我们再次看下这个方法：
    
     private View makeAndAddView(int position, int y, boolean flow, int childrenLeft,
            boolean selected) {
        if (!mDataChanged) {
            // Try to use an existing view for this position.
            final View activeView = mRecycler.getActiveView(position);
            if (activeView != null) {
                // Found it. We're reusing an existing child, so it just needs
                // to be positioned like a scrap view.
                setupChild(activeView, position, y, flow, childrenLeft, selected, true);
                return activeView;
            }
        }

        // Make a new view for this position, or convert an unused view if
        // possible.
        final View child = obtainView(position, mIsScrap);

        // This needs to be positioned and measured.
        setupChild(child, position, y, flow, childrenLeft, selected, mIsScrap[0]);

        return child;
    }

首先会调用getActiveView来获取布局，但是我们之前已经说过，这个方法再次调用会返回null，第二次onLayout方法已经调用过了，所以这里是get不到的，需要继续调用obtainView，obtainView代码如下：

    View obtainView(int position, boolean[] outMetadata) {
        Trace.traceBegin(Trace.TRACE_TAG_VIEW, "obtainView");

        outMetadata[0] = false;

        // Check whether we have a transient state view. Attempt to re-bind the
        // data and discard the view if we fail.
        final View transientView = mRecycler.getTransientStateView(position);
        if (transientView != null) {
            final LayoutParams params = (LayoutParams) transientView.getLayoutParams();

            // If the view type hasn't changed, attempt to re-bind the data.
            if (params.viewType == mAdapter.getItemViewType(position)) {
                final View updatedView = mAdapter.getView(position, transientView, this);

                // If we failed to re-bind the data, scrap the obtained view.
                if (updatedView != transientView) {
                    setItemViewLayoutParams(updatedView, position);
                    mRecycler.addScrapView(updatedView, position);
                }
            }

            outMetadata[0] = true;

            // Finish the temporary detach started in addScrapView().
            transientView.dispatchFinishTemporaryDetach();
            return transientView;
        }

        final View scrapView = mRecycler.getScrapView(position);
        final View child = mAdapter.getView(position, scrapView, this);
        if (scrapView != null) {
            if (child != scrapView) {
                // Failed to re-bind the data, return scrap to the heap.
                mRecycler.addScrapView(scrapView, position);
            } else if (child.isTemporarilyDetached()) {
                outMetadata[0] = true;

                // Finish the temporary detach started in addScrapView().
                child.dispatchFinishTemporaryDetach();
            }
        }

        if (mCacheColorHint != 0) {
            child.setDrawingCacheBackgroundColor(mCacheColorHint);
        }

        if (child.getImportantForAccessibility() == IMPORTANT_FOR_ACCESSIBILITY_AUTO) {
            child.setImportantForAccessibility(IMPORTANT_FOR_ACCESSIBILITY_YES);
        }

        setItemViewLayoutParams(child, position);

        if (AccessibilityManager.getInstance(mContext).isEnabled()) {
            if (mAccessibilityDelegate == null) {
                mAccessibilityDelegate = new ListItemAccessibilityDelegate();
            }
            if (child.getAccessibilityDelegate() == null) {
                child.setAccessibilityDelegate(mAccessibilityDelegate);
            }
        }

        Trace.traceEnd(Trace.TRACE_TAG_VIEW);

        return child;
    }
    
这里我们可以看到，会将从scrapView中取出来的view作为convertView传入getView方法中，将里面地点内容更新为需要的内容，这里还做了个保险措施，要是复用失败会将取出来的scrapView重新放回去。得到view后就会像之前一样，用setUpChild方法attach到listView中。通过上述分析可以看到，在滚动过程中，一旦有view移除，就加入到scrapViews中缓存，平移其他view，形成滑动效果。每次view滑入屏幕时，会调用obtainView方法从缓存中取出view更新内容。换句话来说，除了初次填充之外，移入屏幕的view都是复用了移出屏幕的view。这里可以写代码验证，将第一条item的背景颜色设置为红色，当他完全移出屏幕时你会发现刚移入屏幕的item背景颜色也是红色的。测试代码这里就不放出了。
## 三、总结
listView通过adapter简化数据绑定过程，通过RecycleBin简化数据复用过程，省去了开发过程中的很多工作，这种封装思想需要好好学习。

    
    

    
    

  
  
 
 
 
     
    





