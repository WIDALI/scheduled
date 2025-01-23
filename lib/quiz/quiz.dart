
import 'dart:core';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../screens/algorithm_description.dart';
import '../widgets/organising_tasks.dart';

import 'package:scheduled/hive/node.dart';
import '../globals.dart';
import '../screens/welcome_screen.dart';

class StudyQuizFramework extends StatefulWidget {
  const StudyQuizFramework({super.key});

  @override
  State<StudyQuizFramework> createState() => StudyQuizInterface();
}

class StudyQuizInterface extends State<StudyQuizFramework>
    with SingleTickerProviderStateMixin {
  //i need it for animation control

  Node? currentNode;
  final List<Node> navigationStack = [];
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  String? selectedAlgorithm;

  int? iD; // current node ID
  String? question; // current node description

  // option variables
  String option1Text = "";
  int option1Link = -1;

  String option2Text = "";
  int option2Link = -1;

  String option3Text = "";
  int option3Link = -1;

  // not shwoing yet
  bool isHoveringOption1 = false;
  bool isHoveringOption2 = false;
  bool isHoveringOption3 = false;

  // process text for hovering
  String process1Text = "";
  String process2Text = "";
  String process3Text = "";

  //keep as async!!!! (runs separately from code)
  Future<void> saveAlgorithm(String? algorithm) async {
    if (algorithm == null) return;

    final prefs = await SharedPreferences
        .getInstance(); //basically an interrupt. needed whenever saveAlgorithm is called
    await prefs.setString('selectedAlgorithm', algorithm);
  }

  @override
  void initState() {
    super.initState();

    //animation please workkkkkk
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
            begin: Offset.zero,
            end: Offset
                .zero) // idky this is blocking the animation but if i set it then it automates first movement >_<!!
        .animate(
      CurvedAnimation(
        //thank you Stack
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (decisionMap.isNotEmpty) {
          //first node in map
          currentNode = decisionMap.first;

          // updates :))
          iD = currentNode!
              .id; //i thought i lost you and spent three hours searching. dpmo
          question = currentNode!.description;

          option1Text = currentNode!.options.isNotEmpty
              ? currentNode!.options[0].text
              : "";
          option1Link = currentNode!.options.isNotEmpty
              ? currentNode!.options[0].link
              : -1;
          process1Text = currentNode!.options.isNotEmpty
              ? currentNode!.options[0].process
              : "";

          option2Text = currentNode!.options.length > 1
              ? currentNode!.options[1].text
              : "";
          option2Link = currentNode!.options.length > 1
              ? currentNode!.options[1].link
              : -1;
          process2Text = currentNode!.options.length > 1
              ? currentNode!.options[1].process
              : "";

          option3Text = currentNode!.options.length > 2
              ? currentNode!.options[2].text
              : "";
          option3Link = currentNode!.options.length > 2
              ? currentNode!.options[2].link
              : -1;
          process3Text = currentNode!.options.length > 2
              ? currentNode!.options[2].process
              : "";
        } else {
          // handles the case where the decision map is empty
          print("Decision map is empty.");
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void setSlideDirection(int option) {
    Offset direction;

    if (option == 1) {
      direction = const Offset(-1.0, 0.0); // left -> Option 1
    } else if (option == 2) {
      direction = const Offset(1.0, 0.0); // right -> Option 2
    } else if (option == 3) {
      direction = const Offset(0.0, -1.0); // up -> Option 3
    } else {
      direction = Offset.zero; // default -> no nada zilch
    }

    print("Setting direction for Option $option: $direction"); //debugggg

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: direction,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }
//NOTE: i need you to workkk PLEASEEE tomorrow sort this out, it's so annoying. plays previous buttons movement

  void handleOption(int nextNodeId, int option) {
  
    navigationStack.add(currentNode!);

    _animationController.forward().then((_) {
    _animationController.reset();
    
      
    setState(() {
    // next node ID -1 -> final node
    if (nextNodeId == -1) {
      isLastNode = true; // last node state is set
      isOptionButtonsVisible = false; // hide options
      return; 
    }

      // next node
      for (Node nextNode in decisionMap) {
        if (nextNode.id == nextNodeId) {
            currentNode = nextNode; // update current node
            iD = nextNode.id; // update node ID
            question = nextNode.description; // update q 
            isOptionButtonsVisible = !isLastNode;


            // update options
            option1Text = currentNode!.options.isNotEmpty ? currentNode!.options[0].text : "";
            option1Link = currentNode!.options.isNotEmpty ? currentNode!.options[0].link : -1;
            process1Text = currentNode!.options.isNotEmpty ? currentNode!.options[0].process : "";

            option2Text = currentNode!.options.length > 1 ? currentNode!.options[1].text : "";
            option2Link = currentNode!.options.length > 1 ? currentNode!.options[1].link : -1;
            process2Text = currentNode!.options.length > 1 ? currentNode!.options[1].process : "";

            option3Text = currentNode!.options.length > 2 ? currentNode!.options[2].text : "";
            option3Link = currentNode!.options.length > 2 ? currentNode!.options[2].link : -1;
            process3Text = currentNode!.options.length > 2 ? currentNode!.options[2].process : "";
          
            isLastNode = option1Link == -1 && option2Link == -1 && option3Link == -1;
            isOptionButtonsVisible = !isLastNode;

          break;
        }
        }
      });
    });
  }

// handlers for options
  void option1Handler() {
    //print("Option 1 clicked");
    setSlideDirection(1);
    handleOption(option1Link, 1);
  }

  void option2Handler() {
    //print("Option 2 clicked");
    setSlideDirection(2);
    handleOption(option2Link, 2);
  }

  void option3Handler() {
    //print("Option 3 clicked");
    setSlideDirection(3);
    handleOption(option3Link, 3);
  }

  void goBack() {
    if (navigationStack.isEmpty) {
      // <- WELCOME if on the q1
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    } else {
      // previous q
      setState(() {
        currentNode = navigationStack.removeLast(); // last visited node
        // update details current node
        iD = currentNode!.id;
        question = currentNode!.description;
        isOptionButtonsVisible = !isLastNode;

        option1Text = currentNode!.options.isNotEmpty ? currentNode!.options[0].text : "";
        option1Link = currentNode!.options.isNotEmpty ? currentNode!.options[0].link : -1;
        process1Text = currentNode!.options.isNotEmpty ? currentNode!.options[0].process : "";

        option2Text = currentNode!.options.length > 1 ? currentNode!.options[1].text : "";
        option2Link = currentNode!.options.length > 1 ? currentNode!.options[1].link : -1;
        process2Text = currentNode!.options.length > 1 ? currentNode!.options[1].process : "";

        option3Text = currentNode!.options.length > 2 ? currentNode!.options[2].text : "";
        option3Link = currentNode!.options.length > 2 ? currentNode!.options[2].link : -1;
        process3Text = currentNode!.options.length > 2 ? currentNode!.options[2].process : "";

        isLastNode = currentNode!.options.isEmpty;
        isOptionButtonsVisible = !isLastNode;    
      });
    }
  }

  bool isOptionButtonsVisible = true;
  bool isLastNode = false;

  void toggleButtonsVisibility() {
    setState(() {
      isOptionButtonsVisible = !isOptionButtonsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentNode == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }


    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildBackgroundCards(),
          _buildBackArrow(),
          _buildLogo(),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTitle(),
                _buildCueCards(),

                const SizedBox(height: 40),

                isLastNode ? _buildLastNodeButtons() : _buildOptionButtons()
              ],
            ),
          ),
        ],
      ),
    );
  }

//build widgets

  Widget _buildBackgroundCards() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -50,
          child: Transform.rotate(
            angle: -0.2,
            child: _buildSingleCard(),
          ),
        ),
        Positioned(
          bottom: -50,
          right: -50,
          child: Transform.rotate(
            angle: 0.2,
            child: _buildSingleCard(),
          ),
        ),
        Positioned(
          bottom: -70,
          right: -70,
          child: Transform.rotate(
            angle: 0.15,
            child: _buildSingleCard(),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Transform.rotate(
            angle: -0.1,
            child: _buildSingleCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleCard() {
    return Container(
      width: 300,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFCFC6BA),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), //stack gave me this but idk what other option to change to
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }

  Widget _buildBackArrow() {
    return Positioned(
      top: 16,
      left: 16,
      child: GestureDetector(
        onTap: goBack,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Positioned(
      top: 16,
      right: 16,
      child: Image.asset(
        'assets/images/sign_up.png',
        width: 50,
        height: 50,
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        "HOW DO YOU STUDY BEST?",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCueCards() {
    return SizedBox(
      height: 350,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 3; i >= 1; i--)
            Positioned(
              top: i * 10.0,
              child: Container(
                width: 400,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFFCFC6BA),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: 400,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFFCFC6BA),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    currentNode!.description,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastNodeButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            if (currentNode == null || currentNode!.description.isEmpty) {
              //print("currentNode or description is missing.");
              return;
            }
            setState(() {
              selectedAlgorithm = currentNode!.description;
            });
            await saveAlgorithm(selectedAlgorithm);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryOrganisationFramework(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "NEXT",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            if (currentNode == null || currentNode!.description.isEmpty) {
              //print("currentNode or description is missing.");
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DescriptionAlgorithmFramework(
                  result: currentNode!.description,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "WHAT DOES THIS MEAN?",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildOptionButton(1, option1Text, process1Text, option1Handler),
        _buildOptionButton(3, option3Text, process3Text, option3Handler),
        _buildOptionButton(2, option2Text, process2Text, option2Handler),
      ],
    );
  }

  Widget _buildOptionButton(
    int optionIndex,
    String buttonText,
    String processText,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: optionIndex == 1
                ? Colors.green
                : optionIndex == 2
                    ? Colors.red
                    : const Color(0xffd4a017),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        MouseRegion(
          onEnter: (_) => setState(() => _toggleHover(optionIndex, true)),
          onExit: (_) => setState(() => _toggleHover(optionIndex, false)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/coloured_info.png',
                width: 20,
                height: 20,
              ),
              if (_isHovering(optionIndex))
                Positioned(
                  bottom: -40,
                  child: Text(
                    processText,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

// Hover state handlers
  bool _isHovering(int index) {
    if (index == 1) return isHoveringOption1;
    if (index == 2) return isHoveringOption2;
    if (index == 3) return isHoveringOption3;
    return false;
  }

  void _toggleHover(int index, bool value) {
    if (index == 1) isHoveringOption1 = value;
    if (index == 2) isHoveringOption2 = value;
    if (index == 3) isHoveringOption3 = value;
  }
}
