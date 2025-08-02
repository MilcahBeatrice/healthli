    //    ],
    //                                   ),
    //                                 );
    //                               },
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                     const SizedBox(height: 24),
    //                     // Uses Section
    //                     if (drug.uses.isNotEmpty) ...[
    //                       _buildInfoSection('Uses', drug.uses, Icons.medical_services, const Color(0xFF4CAF50)),
    //                       const SizedBox(height: 24),
    //                     ],
    //                     // Side Effects Section
    //                     if (drug.sideEffects.isNotEmpty) ...[
    //                       _buildInfoSection('Side Effects', drug.sideEffects, Icons.warning_amber, const Color(0xFFFF9800)),
    //                       const SizedBox(height: 24),
    //                     ],
    //                     // Action Buttons
    //                     Row(
    //                       children: [
    //                         Expanded(
    //                           child: ElevatedButton(
    //                             onPressed: () => _onDrugTapped(drug),
    //                             style: ElevatedButton.styleFrom(
    //                               backgroundColor: const Color(0xFF00A86B),
    //                               foregroundColor: Colors.white,
    //                               padding: const EdgeInsets.symmetric(vertical: 16),
    //                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    //                               elevation: 0,
    //                             ),
    //                             child: const Text('Save to History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    //                           ),
    //                         ),
    //                         const SizedBox(width: 16),
    //                         Container(
    //                           width: 56,
    //                           height: 56,
    //                           decoration: BoxDecoration(
    //                             color: Colors.grey[100],
    //                             borderRadius: BorderRadius.circular(16),
    //                           ),
    //                           child: IconButton(
    //                             onPressed: () {
    //                               // Add to favorites functionality
    //                             },
    //                             icon: const Icon(Icons.favorite_outline, color: Colors.grey),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                     const SizedBox(height: 32),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       );
    //     },
    //   ),
    // );