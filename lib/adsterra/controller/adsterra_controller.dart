import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../adsterra_configs.dart';


class AdsterraController extends GetxController {

  Future<void> openSmartLink() async {
    final Uri url = Uri.parse(AdsterraConfigs.smartLinkUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print("Could not launch Smartlink");
    }
  }

  Future<void> openPopunder() async {
    final Uri url = Uri.parse(AdsterraConfigs.popunderUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print("Could not launch Popunder");
    }
  }
}