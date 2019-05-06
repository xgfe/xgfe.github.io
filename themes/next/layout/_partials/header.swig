<h1 class="site-meta">
  <span class="logo-line-before"><i></i></span>
  <a href="{{ config.root }}" class="brand" rel="start">
      <span class="logo">
        <i class="icon-next-logo"></i>
      </span>
      <span class="site-title">{{ config.title }}</span>
  </a>
  <span class="logo-line-after"><i></i></span>
</h1>

<div class="site-nav-toggle">
  <button>
    <span class="btn-bar"></span>
    <span class="btn-bar"></span>
    <span class="btn-bar"></span>
  </button>
</div>

<nav class="site-nav">
  {% set hasSearch = theme.swiftype_key || theme.tinysou_Key %}
  {% set hasSearch = true %}

  {% if theme.menu %}
    <ul id="menu" class="menu {{ hasSearch and 'menu-left' }}">
      {% for name, path in theme.menu %}
        {% set itemName = name.toLowerCase() %}
        <li class="menu-item menu-item-{{ itemName }}">
          <a href="{{ url_for(path) }}" rel="section">
            <i class="menu-item-icon icon-next-{{ itemName }}"></i> <br />
            {{ __('menu.' + itemName) }}
          </a>
        </li>
      {% endfor %}
      <!-- slide-links added by felix -->
      <li class="menu-item menu-item-slides" style="opacity: 1; transform: translateY(0px);">
        <a href="https://xgfe.github.io/Basics/" target="_blank" rel="section">
          <i class="menu-item-icon icon-next-slides"></i> <br>
          Basics
        </a>
      </li>
      <li class="menu-item menu-item-slides" style="opacity: 1; transform: translateY(0px);">
        <a href="https://slides.com/xgfe" target="_blank" rel="section">
          <i class="menu-item-icon icon-next-slides"></i> <br>
          Slides
        </a>
      </li>

      {# Search icon for default scheme #}
      {% if not theme.scheme and theme.swiftype_key %}
        <li class="menu-item menu-item-search">
          <a href="#" class="st-search-show-outputs">
            <i class="menu-item-icon icon-next-search"></i> <br />
            {{ __('menu.search') }}
          </a>
        </li>
      {% endif %}
    </ul>
  {% endif %}

  {% if hasSearch %}
    <div class="site-search">
      {% include 'search.swig' %}
    </div>
  {% endif %}

    <div class="site-search">
      <form class="site-search-form" id="gg-form" action="https://www.google.com/webhp" >
        <input type="text" name="q" id="gg-search-input" class="menu-search-input">
      </form>
    </div>
</nav>
