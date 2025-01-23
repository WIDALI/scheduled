## UP 2246858 --- Scheduled App
- CPU Scheduling and Task Management 
    - (A Flutter app made to help students manage tasks and study schedules efficiently by implementing various and specified CPU scheduling algorithms.)

# Features:
    - Implementation of 22 specific scheduled algorithms
    - Algorithm selection based on a three-choice CSV-based decision path
    - Gantt chart visualisation for results
    - User friendly aesthetic interface with a synonymous colour palette for an enjoyable user experience
    - Task input fields generated based on the selected algorithm
    - Decision Map: https://lucid.app/lucidchart/5a7dcc12-15b9-47f3-b30e-c62d9727b312/edit?viewport_loc=1331%2C2034%2C3347%2C2080%2C0_0&invitationId=inv_9b9ed369-9e69-4f7b-a6e3-555dda734234
    - Use of Shared Preferences for long-term data storage for 
        1. Selected algorithm
        2. Quantum Time 

# CONFIGURATION REQUIREMENTS
    - Flutter SDK Installation 
    - Dependencies installation: 
        flutter pub get
    - Configured for MacOS on XCode
    - Ensure all needed files lib, assets and pubspec.yaml have been downloaded correctly

## HOW TO USE
    - Navigate from Sign Up page to the Study Quiz
    1a. ALGORITHM SELECTION
        - Study quiz to determine the best scheduling algorithm for your study workflow
        - Followed by a brief description of the selected algorithm
    1b. VIDEO PLAYER (optional)
        - AI generated videos (using personal notes of algortihms) to describe the algorithms in terms of studying
    2a. CATEGORY EFFORT ALLOCATION
        - Effort levels (Weights to be used when calculating MLQ algorithms) are assigned by organising the different types of work
    2b. QUANTUM TIME ALLOCATION
        - saved for use in Round Robin algorithms
    2c. DYNAMIC TASK INPUT
        - Enter required inputs respective to the selected algorithm
        - More than one task can be added to me displayed
    3. GANTT CHART OUTPUT
        - Submit tasks to visualise scheduling using a Gantt Chart
    
# Navigation
lib/  
│  
├── main.dart  
├── globals.dart  
│  
├── screens/  #sreens for navigation  
│   ├── welcome_screen.dart  
│   ├── login_screen.dart  
│   ├── algorithm_description.dart  
│   ├── algorithm_results.dart  
│  
├── widgets/  #contain resuable widgets and shared preferences  
│   ├── video_page.dart  
│   ├── organising_tasks.dart  
│   ├── quantum_time.dart  
│  
├── hive/  #hive database for data storage  
│   ├── node.dart  
│   ├── node.g.dart  
│  
├── quiz/  #logic for quiz from CSV  
│   ├── quiz.dart  
│   
└── schedule/                        
    ├── algorithms.dart  
    ├── task_input.dart  
    ├── gantt_chart.dart  


# Technology used
- Dart
- Flutter
- Hive
- SharedPreferences
- Json

## FUTURE IMPROVEMENTS
- Integration of SQL to store email SIGN UP
- Navigation from LOG IN -> Stored Execution State of App
- Ability for user to select algorithms different from the one chosen for them
- Store additional user progress and preferences in a database 
- Integrate Firebase for real-time data synchronisation

# Methodology
1. RESEARCH
    - Researched study productivity techniques such as Pomodoro (used as a framewokr for RR) and analyse how different study techniques can aid in different ways 
    - Explored apps like Flora to see their gamified approach which I wish to implement for future development
    - When creating the specified algorithms, I reviewed different mathematical solutions and how to integrate them to make specialised algorithms
2. DESIGN & DEVELOPMENT
    - Initial designs for GUI were hand drawn on paper before finalisation on FIGMA 
    - Utilisd Hive database to access and manage data from CSV files, allowing for retrieval and integration of outputs and descritions

# Target Audience
    - Students: To manage study schedules, assignments and deadlines, specifically within study periods