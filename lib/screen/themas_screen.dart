import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t4bd/settings/ThemeProvider.dart';

class ThemasScreen extends StatefulWidget {
  const ThemasScreen({super.key});

  @override
  State<ThemasScreen> createState() => _ThemasScreenState();
}

class _ThemasScreenState extends State<ThemasScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cambiar Tema"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThemeOption(
                context,
                icon: Icons.wb_sunny,
                color: Colors.amberAccent,
                title: "Tema Claro",
                themeValue: 'light',
                themeProvider: themeProvider,
              ),
              const SizedBox(height: 20),
              _buildThemeOption(
                context,
                icon: Icons.nights_stay,
                color: Colors.blueGrey,
                title: "Tema Oscuro",
                themeValue: 'dark',
                themeProvider: themeProvider,
              ),
              const SizedBox(height: 20),
              // Font Selection
              Card(
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.font_download, color: Colors.blue),
                  title: const Text("Fuente"),
                  trailing: DropdownButton<String>(
                    value: themeProvider.currentFont,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        themeProvider.setFont(newValue);
                      }
                    },
                    items: ['Roboto', 'Doto', 'Courier New', 'Edu']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // Padding(
    //   padding: const EdgeInsets.all(20.0),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       // Título de la pantalla
    //       Text(
    //         "Seleccione el Tema",
    //         style: Theme.of(context).textTheme.headlineSmall?.copyWith(
    //               fontWeight: FontWeight.bold,
    //               color: Theme.of(context).brightness == Brightness.dark
    //                   ? Colors.white
    //                   : Colors.black,
    //             ),
    //       ),
    //       const SizedBox(height: 20),

    //       // Botones para cambiar entre modo claro y oscuro
    //       Column(
    //         children: [
    //           SizedBox(
    //             width: double.infinity,
    //             child: ElevatedButton.icon(
    //               onPressed: () {
    //                 // themeProvider.setThemeMode(ThemeMode.light);
    //               },
    //               style: ElevatedButton.styleFrom(
    //                 // backgroundColor:
    //                 //     themeProvider.themeMode == ThemeMode.light
    //                 //         ? Colors.deepPurple
    //                 //         : const Color.fromARGB(255, 253, 253, 253),
    //                 padding: const EdgeInsets.symmetric(vertical: 15),
    //                 shape: RoundedRectangleBorder(
    //                   borderRadius: BorderRadius.circular(12),
    //                 ),
    //                 elevation: 5,
    //               ),
    //               icon: Icon(
    //                 Icons.wb_sunny,
    //                 size: 20,
    //                 // color: themeProvider.themeMode == ThemeMode.light
    //                 //     ? Colors.white
    //                 //     : Colors.black,
    //               ),
    //               label: Text(
    //                 "Modo Claro",
    //                 style: TextStyle(
    //                   fontSize: 16,
    //                   // color: themeProvider.themeMode == ThemeMode.light
    //                   //     ? Colors.white
    //                   //     : Colors.black,
    //                 ),
    //               ),
    //             ),
    //           ),
    //           const SizedBox(height: 15),
    //           SizedBox(
    //             width: double.infinity,
    //             child: ElevatedButton.icon(
    //               onPressed: () {
    //                 // themeProvider.setThemeMode(ThemeMode.dark);
    //               },
    //               style: ElevatedButton.styleFrom(
    //                 // backgroundColor: themeProvider.themeMode == ThemeMode.dark
    //                 //     ? Colors.deepPurple
    //                 //     : const Color.fromARGB(255, 255, 255, 255),
    //                 padding: const EdgeInsets.symmetric(vertical: 15),
    //                 shape: RoundedRectangleBorder(
    //                   borderRadius: BorderRadius.circular(12),
    //                 ),
    //                 elevation: 5,
    //               ),
    //               icon: Icon(
    //                 Icons.nights_stay,
    //                 size: 20,
    //                 // color: themeProvider.themeMode == ThemeMode.dark
    //                 //     ? Colors.white
    //                 //     : Colors.black,
    //               ),
    //               label: Text(
    //                 "Modo Oscuro",
    //                 style: TextStyle(
    //                   fontSize: 16,
    //                   // color: themeProvider.themeMode == ThemeMode.dark
    //                   //     ? Colors.white
    //                   //     : Colors.black,
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //       const SizedBox(height: 30),

    //       // Título para la selección de fuente
    //       Text(
    //         "Seleccione la Fuente",
    //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
    //               fontWeight: FontWeight.w500,
    //               color: Theme.of(context).brightness == Brightness.dark
    //                   ? Colors.white70
    //                   : Colors.black54,
    //             ),
    //       ),
    //       const SizedBox(height: 20),

    //       // Botones para la selección de fuente
    //       Wrap(
    //         spacing: 12.0,
    //         runSpacing: 12.0,
    //         children: <String>['Roboto', 'Pacifico', 'Lobster', 'Open Sans']
    //             .map((font) {
    //           final isPremium = font != 'Roboto';

    //           return Stack(
    //             children: [
    //               SizedBox(
    //                 width: screenWidth < 600
    //                     ? (screenWidth - 64) / 2
    //                     : (screenWidth - 88) / 4,
    //                 child: ElevatedButton(
    //                   onPressed: isPremium
    //                       ? null
    //                       : () {
    //                           // themeProvider.setFontFamily(font);
    //                         },
    //                   style: ElevatedButton.styleFrom(
    //                     padding: const EdgeInsets.symmetric(
    //                       horizontal: 20,
    //                       vertical: 12,
    //                     ),
    //                     shape: RoundedRectangleBorder(
    //                       borderRadius: BorderRadius.circular(12),
    //                     ),
    //                     elevation: 3,
    //                     // backgroundColor: isPremium
    //                     //     ? Colors.grey[300]
    //                     //     : themeProvider.fontFamily == font
    //                     //         ? Colors.deepPurple.withOpacity(0.2)
    //                     //         : Colors.grey[200],
    //                   ),
    //                   child: Row(
    //                     mainAxisAlignment: MainAxisAlignment.center,
    //                     children: [
    //                       Text(
    //                         font,
    //                         textAlign: TextAlign.center,
    //                         style: TextStyle(
    //                           fontFamily: font,
    //                           fontSize: screenWidth < 600 ? 12 : 14,
    //                           // color: isPremium
    //                           //     ? Colors.grey
    //                           //     : themeProvider.fontFamily == font
    //                           //         ? Colors.deepPurple
    //                           //         : Colors.black,
    //                         ),
    //                       ),
    //                       // Corona amarilla para fuentes premium
    //                       if (isPremium) const SizedBox(width: 5),
    //                       if (isPremium)
    //                         const Icon(
    //                           Icons.emoji_events,
    //                           size: 18,
    //                           color: Colors.amber,
    //                         ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           );
    //         }).toList(),
    //       ),
    //     ],
    //   ),
    // ),
    // );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String themeValue,
    required ThemeProvider themeProvider,
  }) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: Radio<String>(
          value: themeValue,
          groupValue: themeProvider.currentTheme,
          onChanged: (value) {
            if (value != null) {
              themeProvider.setTheme(value);
            }
          },
        ),
      ),
    );
  }
}
