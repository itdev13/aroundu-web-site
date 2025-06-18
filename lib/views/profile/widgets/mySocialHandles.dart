
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/views/auth/auth.service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialHandlesScreen extends StatefulWidget {
  final List<Map<String, String>> socialMediaLinks;

  const SocialHandlesScreen({super.key, required this.socialMediaLinks});

  @override
  State<SocialHandlesScreen> createState() => _SocialHandlesScreenState();
}

class _SocialHandlesScreenState extends State<SocialHandlesScreen> {
  bool isEditing = false;
  List<Map<String, String>> editedLinks = [];
  String? newLinkType;
  String newLinkUrl = "";

  @override
  void initState() {
    super.initState();
    editedLinks = List.from(widget.socialMediaLinks);
  }

Future<Response?> socialMediaHandel(String type, String url) async {
    try {
      final headers = await AuthService().getAuthHeaders();
      const postRequestUrl =
          "https://api.aroundu.in/user/api/v1/updateProfileMedia";

      FormData formData = FormData.fromMap({"type": type, "url": url});

      Dio dio = Dio();
      final response = await dio.post(
        postRequestUrl,
        data: formData,
        options: Options(
          headers: {
            "Authorization": headers['Authorization'],
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Social media link created successfully: ${response.data}");
        return response;
      } else {
        print("Error creating socialMediaLink: ${response.statusCode}");
        return response;
      }
    } catch (e, stack) {
      print("API Error: $e \n $stack");
      rethrow;
    }
  }

  final Map<String, IconData> iconMap = {
    "IG": Icons.camera_alt_outlined,
    "FB": Icons.facebook,
    "YOUTUBE": Icons.ondemand_video,
    "LINKEDIN": Icons.business_center
  };

  Future<void> updateSocialMediaLink(String type, String url) async {
    // Simulate API Call (Replace with actual API call)
    await socialMediaHandel(type, url);
    // await Future.delayed(Duration(seconds: 1));

    // If API call is successful, reload UI
    setState(() {
      int index = editedLinks.indexWhere((item) => item['type'] == type);
      if (index != -1) {
        editedLinks[index]['url'] = url;
      } else {
        editedLinks.add({"type": type, "url": url});
      }
      newLinkType = null;
      newLinkUrl = "";
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> availableTypes = ["FB", "IG", "YOUTUBE", "LINKEDIN"]
        .where((type) => !editedLinks.any((link) => link["type"] == type))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const DesignText(
          text: "My Social Handles",
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : LucideIcons.edit,
                color: Colors.black),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                ...editedLinks.map((link) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(iconMap[link['type']] ?? Icons.link,
                                size: 28, color: Colors.blueGrey),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DesignText(
                                text: link['type'] ?? "Unknown",
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              isEditing
                                  ? TextFormField(
                                      initialValue: link['url'],
                                      onChanged: (value) {
                                        setState(() {
                                          link['url'] = value.trim();
                                        });
                                      },
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        final Uri url =
                                            Uri.parse(link['url'] ?? "");
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        }
                                      },
                                      child: DesignText(
                                        text: link['url'] ?? "",
                                        fontSize: 14,
                                        color: Color(0xFF3E79A1),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        if (isEditing)
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              updateSocialMediaLink(
                                  link['type']!, link['url']!);
                            },
                          )
                      ],
                    ),
                  );
                }).toList(),

                // Add new social handle section
                if (availableTypes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        newLinkType = availableTypes.first;
                      });
                    },
                    child: _socialHandleTile(
                      icon: Icons.add,
                      title: "Add New",
                      subtitle: "",
                      isAddNew: true,
                    ),
                  ),
                ],

                // New social handle input
                if (newLinkType != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(iconMap[newLinkType] ?? Icons.link,
                                size: 28, color: Colors.blueGrey),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButton<String>(
                                value: newLinkType,
                                items: availableTypes.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    newLinkType = value;
                                  });
                                },
                              ),
                              TextFormField(
                                onChanged: (value) {
                                  newLinkUrl = value.trim();
                                },
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            if (newLinkType != null && newLinkUrl.isNotEmpty) {
                              updateSocialMediaLink(newLinkType!, newLinkUrl);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialHandleTile(
      {required IconData icon,
      required String title,
      required String subtitle,
      bool isAddNew = false}) {
    return Row(
      children: [
        Icon(icon, size: 28, color: Colors.blueGrey),
        const SizedBox(width: 12),
        Text(title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
