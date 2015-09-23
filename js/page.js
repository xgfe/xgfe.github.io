
(function($){

    function init(){
      $('.fancybox').fancybox();
      initScrollHandler();
      initSearchBox();
      initPaginationCtrl();
      // $('div.post-content header h1').on('click', function(){
      //   console.log('youclickme');
      //   toggleFull();
      // });
    }

    var initScrollHandler = function(){
      function goTop() {
          $(window).scroll(function(e) {
              // If the distance between scrollbar and top border is more than 100 pix
              if($(window).scrollTop() > 100)
                  $("#go-pg-top").fadeIn().css({ opacity: 0.6 });
              else
                  $("#go-pg-top").fadeOut();
          });
      };  

      $("#go-pg-top").click(function(e) {
          $('body,html').animate({scrollTop:0}, 200);
      });
      $("#go-pg-top").mouseover(function(e) {
          $(this).css({ opacity: 1 });
      });
      $("#go-pg-top").mouseout(function(e) {
          $(this).css({ opacity: 0.6 });
      });
      // Scroll to top
      goTop();
    };

    var initSearchBox = function(){
      $('#sidebar i.icon-search').on({
        'click': function(){
            $('#sidebar form')[0].submit();
        },
        'mouseover': function(){
            $(this).addClass('search-hover');
        },
        'mouseout':function(){
            $(this).removeClass('search-hover');
        }
      });
    };

    var initPaginationCtrl = function(){
      var $prev = $('#pagination .prev'),
          $next = $('#pagination .next'),
          $pgPrev = $('#page-direction .page-prev'),
          $pgNext = $('#page-direction .page-next');

      if($prev.length){
          $pgPrev.show().attr('href', $prev.attr('href'));
          $prev.hide();
      }else{
          $pgPrev.hide();
      }
      if($next.length){
          $pgNext.show().attr('href', $next.attr('href'));
          $next.hide();
      }else{
          $pgNext.hide();
      }

      $pgPrev.on({
        'mouseover': function(){
            $(this).addClass('page-prev-hover');
        },
        'mouseout': function(){
            $(this).removeClass('page-prev-hover');
        }
      });  

      $pgNext.on({
        'mouseover': function(){
            $(this).addClass('page-next-hover');
        },
        'mouseout': function(){
            $(this).removeClass('page-next-hover');
        }
      });
    };

    var cancelFullScreen = function(el){
        var requestMethod = el.cancelFullScreen||el.webkitCancelFullScreen||el.mozCancelFullScreen||el.exitFullscreen;
        if (requestMethod) { // cancel full screen.
            requestMethod.call(el);
        } else if (typeof window.ActiveXObject !== "undefined") { // Older IE.
            var wscript = new ActiveXObject("WScript.Shell");
            if (wscript !== null) {
                wscript.SendKeys("{F11}");
            }
        }
    };

    var requestFullScreen = function(el){
        // Supports most browsers and their versions.
        var requestMethod = el.requestFullScreen || el.webkitRequestFullScreen || el.mozRequestFullScreen || el.msRequestFullScreen;

        if (requestMethod) { // Native full screen.
            requestMethod.call(el);
        } else if (typeof window.ActiveXObject !== "undefined") { // Older IE.
            var wscript = new ActiveXObject("WScript.Shell");
            if (wscript !== null) {
                wscript.SendKeys("{F11}");
            }
        }
        return false
    };

    var toggleFull = function(){
        var elem = $('#content article.post')[0]; // Make the body go full screen.
        var isInFullScreen = (document.fullScreenElement && document.fullScreenElement !== null) ||  (document.mozFullScreen || document.webkitIsFullScreen);

        if (isInFullScreen) {
            cancelFullScreen(document);
        } else {
            requestFullScreen(elem);
        }
        return false;
    };

    init();

})(jQuery);
