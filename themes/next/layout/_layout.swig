<!doctype html>
<html class="theme-next {% if theme.use_motion %}use-motion{% endif %} {% if theme.scheme %}theme-next-{{ theme.scheme | lower }}{% endif %}">
<head>
  {% include '_partials/head.swig' %}
  <title>{% block title %}{% endblock %}</title>
  <link rel="stylesheet" href="https://aimingoo.github.io/gitmint/style/default.css">
</head>

<body itemscope itemtype="http://schema.org/WebPage" lang="{{ config.language }}">
  <div style="position: fixed; top: -9999px; left: -9999px;">
    <img src="http://p0.meituan.net/xgfe/082a9624ba5ae8602150a2d43968463e49348.png" alt="xgfe"/>
  </div>
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
        {% if page.comments %}
          <div id="comments" class="article-info article-info-index"></div>
        {% endif %}
      </div>

      {% block sidebar %}{% endblock %}
    </main>

    <footer id="footer" class="footer">
      <div class="footer-inner"> {% include '_partials/footer.swig' %} </div>
    </footer>

    <div class="back-to-top"></div>
  </div>
  <script type="text/javascript" src="{{ url_for(theme.vendors) }}/gitmint.browser.js"></script>
  <script type="text/javascript" src="{{ url_for(theme.vendors) }}/jquery/index.js?v=2.1.3"></script>

  {# This block is used to set options before any other scripts run #}
  {% block script_extra_before %}{% endblock %}
  {% block comment_system %}
    {% include '_scripts/comments/gitment.swig' %}
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
          location.href = 'https://www.google.com.hk/?gfe_rd=cr&ei=hXw8VpjtHuLC8AeSuIjQAg&gws_rd=ssl#safe=strict&q='+encodeURIComponent(keyword)+'+site:xgfe.github.io';
        }
        return false;
      });
  </script>
  <!-- baidu 站长自动推送 -->
  <script>
  (function(){
      var bp = document.createElement('script');
      bp.src = '//push.zhanzhang.baidu.com/push.js';
      var s = document.getElementsByTagName("script")[0];
      s.parentNode.insertBefore(bp, s);
  })();
  </script>
</body>
</html>
