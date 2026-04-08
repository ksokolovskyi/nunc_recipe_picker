import 'package:flutter/material.dart';
import 'package:nunc_recipe_picker/recipe_picker.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: _Picker(),
      ),
    );
  }
}

class _Picker extends StatefulWidget {
  const _Picker();

  @override
  State<_Picker> createState() => __PickerState();
}

class __PickerState extends State<_Picker> {
  final RecipePickerConfig? _config = RecipePickerConfig.tryParse('''
<svg width="365" height="365" viewBox="0 0 365 365" fill="none" xmlns="http://www.w3.org/2000/svg">
<path id="picker_area" d="M169.329 68.67c27.5-21.834 89.1-64.7 115.5-61.5m15 0c21 3.667 62.8 29.702 62 104.502m-1.5 14.5c.833 11.333-6.4 52.1-42 124.5m-7.5 12.5c-29.5 45.5-67.4 112.3-147 91.5m-14.5-4c-19.333-6.167-67.4-30.5-105-78.5m-18-129c-17.833 12.833-41.1 54.2 8.5 117m122-182.5c-49 32-91.5 42.5-118 56" stroke="#FAB150" stroke-width="5" stroke-linecap="round"/>
<path id="espresso_area" d="M182.328 250.515C217.86 206.869 239.032 158.776 211.218 126.134C183.405 93.4916 141.493 123.358 107.063 133.972C9.46628 164.06 23.2873 224.862 61.916 265.794C100.545 306.726 148.199 292.437 182.328 250.515Z" stroke="#FDFDFD" stroke-width="6"/>
<circle id="espresso_area_base" cx="87.8289" cy="219" r="9" fill="#4E4B4A"/>
<path id="ristretto_area" d="M327.831 179.492C374.63 98.9954 337.83 27.0007 300.829 19.4964C263.828 11.9921 220.329 44.0575 204.329 57.4997C151.339 102.018 166.328 131.85 194.327 173.498C222.326 215.147 286.002 251.439 327.831 179.492Z" stroke="#FDFDFD" stroke-width="6"/>
<circle id="ristretto_area_base" cx="293.829" cy="62" r="9" fill="#4E4B4A"/>
<path id="lungo_area" d="M297.329 255C343.329 222 347.329 169 298.329 146.5C249.329 124 217.977 94.9743 163.33 119.135C104.829 145 105.328 231.004 143.828 258.999C182.328 286.993 236.369 298.732 297.329 255Z" stroke="#FDFDFD" stroke-width="6"/>
<circle id="lungo_area_base" cx="285.829" cy="196" r="9" fill="#4E4B4A"/>
<circle id="thumb" cx="45" cy="45" r="45"/>
</svg>
''');

  Recipe _recipe = Recipe.espresso;

  @override
  Widget build(BuildContext context) {
    if (_config == null) {
      return const Center(
        child: Text(
          'Config loading failed.',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: RecipePicker(
          config: _config,
          recipe: _recipe,
          onChanged: (recipe) {
            setState(() {
              _recipe = recipe;
            });
          },
        ),
      ),
    );
  }
}
