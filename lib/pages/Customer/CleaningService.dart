import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:taskmaster/pages/Customer/Details/CleaningServiceDetails.dart';

class CleaningServices extends StatefulWidget {
  @override
  _CleaningServiceState createState() => _CleaningServiceState();
}

class _CleaningServiceState extends State<CleaningServices> {
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> filteredServices = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  void fetchServices() {
    DatabaseReference ref = FirebaseDatabase.instance.ref("companies");
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        List<Map<String, dynamic>> tempList = [];
        data.forEach((companyId, companyData) {
          if (companyData["services"] != null) {
            final servicesData = companyData["services"] as Map<dynamic, dynamic>;
            servicesData.forEach((serviceId, serviceDetails) {
              if (serviceDetails["serviceType"] == "Cleaning service") {
                tempList.add({"serviceId": serviceId, ...serviceDetails});
              }
            });
          }
        });
        setState(() {
          services = tempList;
          filteredServices = tempList;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void filterServices(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredServices = services;
      } else {
        filteredServices = services
            .where((service) => service["serviceName"].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cleaning Services", style: GoogleFonts.poppins(fontWeight: FontWeight.bold,color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              onChanged: filterServices,
              decoration: InputDecoration(
                hintText: "Search services...",
                hintStyle: GoogleFonts.poppins(),
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          isLoading
              ? Expanded(child: Center(child: CircularProgressIndicator(color: Colors.teal)))
              : Expanded(
            child: filteredServices.isEmpty
                ? Center(child: Text("No Cleaning Services Found", style: GoogleFonts.poppins()))
                : Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2, // Adaptive columns
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: MediaQuery.of(context).size.width > 600 ? 0.8 : 0.9, // Adjust aspect ratio
                  ),
                  itemCount: filteredServices.length,
                  itemBuilder: (context, index) {
                    var service = filteredServices[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CleaningServiceDetails(service: service),
                          ),
                        );
                      },
                      child: FadeInUp(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                  child: CachedNetworkImage(
                                    imageUrl: service["imageUrl"],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(service["serviceName"],
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600, fontSize: 14)),
                                    SizedBox(height: 5),
                                    Text("Price: \Rs. ${service["price"]}",
                                        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.access_time, color: Colors.teal, size: 14),
                                        SizedBox(width: 4),
                                        Text("${service["duration"]} hrs",
                                            style: GoogleFonts.poppins(fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

              ),

            ),
          ),
        ],
      ),
    );
  }
}
