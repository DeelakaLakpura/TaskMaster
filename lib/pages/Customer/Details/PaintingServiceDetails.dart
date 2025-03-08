import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class PaintingServiceDetails extends StatelessWidget {
  final Map<String, dynamic> service;

  PaintingServiceDetails({required this.service});

  void _launchWhatsApp() async {
    final phone = service["phone"] ?? '+1234567890';
    final message = "Hi, I'm interested in ${service["serviceName"]} service";
    final url = "https://wa.me/$phone?text=${Uri.encodeFull(message)}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service["serviceName"],
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[800]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  height: 300,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30)),
                    child: CachedNetworkImage(
                      imageUrl: service["imageUrl"],
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error, size: 50),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent
                      ],
                    ),
                  ),
                  child: Text(
                    service["serviceName"],
                    style: GoogleFonts.poppins(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    icon: Icons.currency_rupee_sharp,
                    title: "Price",
                    value: "Rs. ${service["price"]}",
                    color: Colors.green,
                  ),
                  SizedBox(height: 15),
                  _buildInfoCard(
                    icon: Icons.access_time,
                    title: "Duration",
                    value: "${service["duration"]} hours",
                    color: Colors.blue,
                  ),
                  SizedBox(height: 25),
                  Text("Service Details",
                      style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  Divider(thickness: 2),
                  SizedBox(height: 10),
                  Text(service["description"] ?? "No description available",
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          height: 1.5)),
                  SizedBox(height: 30),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _launchWhatsApp,
                        icon: Image.asset(
                          'assets/images/whatsapp.png',
                          height: 28,

                        ),
                        label: Text("Contact via WhatsApp",
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[500],
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: color),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14)),
              Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
        ],
      ),
    );
  }
}