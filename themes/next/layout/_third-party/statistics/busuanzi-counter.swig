{%- if theme.busuanzi_count.enable %}
<div class="busuanzi-count">
  <script async src="https://busuanzi.ibruce.info/busuanzi/2.3/busuanzi.pure.mini.js"></script>
  
  <span class="site-uv" title="{{ __('footer.total_visitors') }}">
    我的第<span id="busuanzi_value_site_uv"></span>位朋友, 
  </span>

  <span class="site-pv" title="{{ __('footer.total_views') }}">
    经过<span id="busuanzi_value_site_pv"></span>次回眸与你相遇
  </span>
</div>
{%- endif %}
