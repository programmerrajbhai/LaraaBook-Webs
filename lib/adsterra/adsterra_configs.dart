class AdsterraConfigs {
  // ============================================================
  // ✅ ১. ব্যানার কি (Key) - এগুলো আগের মতোই থাকবে
  // ============================================================

  static const String key300x250 = "9964ceedd636bc71ee33b5cde8683614";
  static const String key728x90 = "d9fb810eaeb7bf3314e5e11eabebed8b";
  static const String keyNative = "8e8a276d393bb819af043954cc38995b";

  // Social Bar Script
  static const String srcSocialBar = "https://pl25522730.effectivegatecpm.com/dd/4f/78/dd4f7878c3a97f6f9e08bdf8911ad44b.js";


  // ============================================================
  // ✅ ২. স্মার্ট লিংক আপডেট (AdGuard বাইপাস করার জন্য)
  // ============================================================

  // ❌ আগের ডিরেক্ট লিংক (এটি AdGuard ব্লক করত)
  // static const String smartLinkUrl = "https://www.effectivegatecpm.com/n90473c2?key=...";

  // ✅ নতুন লিংক (আপনার ওয়েবসাইটের রিডাইরেক্ট লিংক)
  static const String smartLinkUrl = "https://laraabook.com/api/go.php";

  // পপঅন্ডারও একই লিংক ব্যবহার করবে
  static const String popunderUrl = smartLinkUrl;


  // ============================================================
  // ⚠️ ৩. HTML কোড জেনারেটর (হাত দেওয়ার দরকার নেই)
  // ============================================================

  static String get html300x250 => """
    <script type="text/javascript">
       atOptions = {
          'key' : '$key300x250',
          'format' : 'iframe',
          'height' : 250,
          'width' : 300,
          'params' : {}
       };
    </script>
    <script type="text/javascript" src="https://www.highperformanceformat.com/$key300x250/invoke.js"></script>
  """;

  static String get html728x90 => """
    <script type="text/javascript">
       atOptions = {
          'key' : '$key728x90',
          'format' : 'iframe',
          'height' : 90,
          'width' : 728,
          'params' : {}
       };
    </script>
    <script type="text/javascript" src="https://www.highperformanceformat.com/$key728x90/invoke.js"></script>
  """;

  static String get htmlSocialBar => """
    <script type='text/javascript' src='$srcSocialBar'></script>
  """;

  static String get htmlNative => """
    <script async="async" data-cfasync="false" src="https://pl25493353.effectivegatecpm.com/$keyNative/invoke.js"></script>
    <div id="container-$keyNative"></div>
  """;
}