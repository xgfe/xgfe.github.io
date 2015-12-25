<!doctype html>
<html class="theme-next {% if theme.use_motion %}use-motion{% endif %} {% if theme.scheme %}theme-next-{{ theme.scheme | lower }}{% endif %}">
<head>
  {% include '_partials/head.swig' %}
  <title>{% block title %}{% endblock %}</title>
</head>

<body itemscope itemtype="http://schema.org/WebPage" lang="{{ config.language }}">

  {% include '_partials/old-browsers.swig' %}
  {% include '_scripts/analytics.swig' %}

  <div class="container one-column {% block page_class %}{% endblock %}">
    <div class="headband"></div>

    <header id="header" class="header" itemscope itemtype="http://schema.org/WPHeader">
      <div class="header-inner"> {%- include '_partials/header.swig' %} </div>
    </header>

    <main id="main" class="main">
      <div class="main-inner">
        <div id="content" class="content"> {% block content %}{% endblock %} </div>

        {% if (theme.duoshuo_hotartical and page.title) %}
            <!-- 多说热评文章-->
            <p>热评文章</p>
            <div class="ds-top-threads" data-range="weekly" data-num-items="4"></div>
        {% endif %}

        {% if page.comments %}
          <div class="comments" id="comments">
            {% if (theme.duoshuo and theme.duoshuo.shortname) or theme.duoshuo_shortname %}
              <div class="ds-thread" data-thread-key="{{ page.path }}"
                   data-title="{{ page.title }}" data-url="{{ page.permalink }}">
              </div>
            {% elseif theme.disqus_shortname %}
              <div id="disqus_thread">
                <noscript>Please enable JavaScript to view the <a href="//disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
              </div>
            {% endif %}
          </div>
        {% endif %}
      </div>

      {% block sidebar %}{% endblock %}
    </main>

    <footer id="footer" class="footer">
      <div class="footer-inner"> {% include '_partials/footer.swig' %} </div>
    </footer>

    <div class="back-to-top"></div>
  </div>

  <script type="text/javascript" src="{{ url_for(theme.vendors) }}/jquery/index.js?v=2.1.3"></script>

  {# This block is used to set options before any other scripts run #}
  {% block script_extra_before %}{% endblock %}
  {% block comment_system %}
    {% include '_scripts/comments/duoshuo.swig' %}
    {% include '_scripts/comments/disqus.swig' %}
  {% endblock %}
  {% include '_scripts/fancy-box.swig' %}
  {% include '_scripts/helpers.swig' %}
  {% include '_scripts/motion.swig' %}

  <script type="text/javascript" src="{{ url_for(theme.js) }}/nav-toggle.js?v={{ theme.version }}"></script>
  <script type="text/javascript" src="{{ url_for(theme.vendors) }}/fastclick/lib/fastclick.min.js?v=1.0.6"></script>

  {% block script_extra %}{% endblock %}

  <script type="text/javascript">
    $(document).ready(function () {
      if (CONFIG.sidebar === 'always') {
        displaySidebar();
      }
      if (isMobile()) {
        FastClick.attach(document.body);
      }
    });
  </script>

  {% include '_scripts/mathjax.swig' %}
  {% block comment_system %}{% endblock %}
  {% include '_scripts/baidushare.swig' %}

  {# LazyLoad #}
  <script type="text/javascript" src="{{ url_for(theme.js) }}/lazyload.js"></script>
  <script type="text/javascript">
    $(function () {
      $("#posts").find('img').lazyload({
        placeholder: "{{ url_for(theme.images) }}/loading.gif",
        effect: "fadeIn"
      });
    });
  </script>
  
  <!-- google search, added by felix -->
  <script>
      $('#gg-form').on('submit', function(e) {
        var keyword = $.trim($(this).find('#gg-search-input').val());
        if (keyword) {
          location.href = 'https://www.google.com.hk/?gfe_rd=cr&ei=hXw8VpjtHuLC8AeSuIjQAg&gws_rd=ssl#safe=strict&q='+encodeURIComponent(keyword)+'+site:xgfe.github.io%2Fblog';
        }
        return false;
      });
  </script>
  <!-- share for weixin -->
  <script>
    var $description = $('meta[name="description"]');
    var dataForWeixin={
      appId: "",
      img: "http://xgfe.github.io/uploads/xg-logo.jpg",
      url: location.href,
      title: $('title').text(),
      desc: $description.eq($description.length - 1).attr('content'),
      fakeid: ""
    };
    !function(){var t=function(){
      WeixinJSBridge.on("menu:share:appmessage",function(){
        WeixinJSBridge.invoke("sendAppMessage",{appid:dataForWeixin.appId,img_url:dataForWeixin.img,img_width:"200",img_height:"200",link:dataForWeixin.url,desc:dataForWeixin.desc,title:dataForWeixin.title},function(){})}),
      WeixinJSBridge.on("menu:share:timeline",function(){WeixinJSBridge.invoke("shareTimeline",{img_url:dataForWeixin.img,img_width:"200",img_height:"200",link:dataForWeixin.url,desc:dataForWeixin.desc,title:dataForWeixin.title},function(){})}),WeixinJSBridge.on("menu:share:weibo",function(){WeixinJSBridge.invoke("shareWeibo",{content:dataForWeixin.title+" "+dataForWeixin.url,url:dataForWeixin.url},function(){})})};document.addEventListener?document.addEventListener("WeixinJSBridgeReady",t,!1):document.attachEvent&&(document.attachEvent("WeixinJSBridgeReady",t),document.attachEvent("onWeixinJSBridgeReady",t))}();
  </script>
</body>
</html>
