import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'style/colors.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, ctis) {
      return SizedBox(
        width: ctis.maxWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Smart Farm (basic)',
              style: GoogleFonts.sofia(
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(
              width: ctis.maxWidth / 2.6,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding:
                              const EdgeInsets.only(left: 40.0, right: 5),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                const BorderSide(color: AppColors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                const BorderSide(color: AppColors.white),
                          ),
                          prefixIcon:
                              const Icon(Icons.search, color: AppColors.black),
                          hintText: 'Search',
                          hintStyle: const TextStyle(
                              color: AppColors.secondary, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class PopupMenuButtonShape extends StatelessWidget {
  void Function()? onPressed;
  PopupMenuButtonShape({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        // margin: const EdgeInsets.only(left: defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.secondaryBg.withOpacity(0.5),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: Icon(Icons.menu, size: 40),
        ),
      ),
    );
  }
}
