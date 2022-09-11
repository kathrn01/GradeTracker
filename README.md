#  GradeTracker

## About GradeTracker
GradeTracker is a program that aims to simplify the student experience by allowing a user to manage courses and syllabus items by entering a "goal" grade for a course, and the program can then calculate and display a target grade which the student will need to achieve on syllabus items to meet that goal grade in the course. The target grade adjusts as necessary when final grades are assigned to syllabus items, or if the weight or final grade is adjusted for any syllabus item.
The visual component of progress towards a goal grade as well as exact figures in terms of criteria necessary to achieve the goal can hopefully empower and motivate students.

| Terms | Courses | Syllabus Items |
| ---- | ---- | ---- |
| ![Screen Shot 2022-09-11 at 12 49 54 PM](https://user-images.githubusercontent.com/84199502/189553635-0d4d2a0e-5203-4faf-a5cf-5f52f1dac5de.png) | ![Screen Shot 2022-09-11 at 12 52 48 PM](https://user-images.githubusercontent.com/84199502/189553649-43ca072a-eb96-4865-87db-117a2fc445ca.png) | ![Screen Shot 2022-09-11 at 6 47 34 PM](https://user-images.githubusercontent.com/84199502/189554100-dc13cf84-1fe6-4860-92c0-d2c4d85ad73a.png) |

## Packages and Major Source Code Organization 
### The code is organized at present into "Model" and "View" and will soon have "ViewModel" introduced. 
Model contains the logic and Core Data files, while View contains UI files. ViewModel will contain files/code that behave as intermediaries, to ensure that the Model and the View code can more safely interact.

### Built With
#### Development Environment: XCode
#### Languages: Swift, SwiftUI
#### Persistence Framework: Core Data

## Usage 
### Adding A Term
#### The user may add a term name, start and end dates, and choose a marker colour.
The terms will display in a list on the main page, with the most recent start date at the top (they are ordered from most to least recent start date).
The user can edit these attributes in the term's main page, which is accessed by selecting the term from the main page.

### Adding A Course To A Term
#### The user may add a course name and a goal grade.
These attributes can be edited in the course's main page, which is accessed by selecting the course from the term's page.

### Adding A Syllabus Item To A Course
#### The user may add a syllabus item name, it's weight (percentage of the course it's worth), it's due date and time, and optionally a final grade (this can be added later)
These attributes can be edited by selecting the syllabus item when it's displayed on the course page.
#### NOTE: The target grade for syllabus items will not be displayed until the sum of weights total 100% or more. In other words, until all syllabus items are added. See demo video below (adding final grade to syllabus item) to view how the target grade is displayed once all syllabus items are added.

### Adding Final Grade To Syllabus Item
#### If the Syllabus Item was added without an initial grade, one can be added by selecting the item in the list. Once the final grade is added for that item, it's display will change to show a progress bar and the percentage achieved, and the target grade will adjust accordingly for subsequent un-marked syllabus items. 

## Testing
Tests have been written for the Course class so far, and more tests will be added (UI tests). The main functionality of correctly calculating the target grade for syllabus items in a course has been tested in the CourseTests class.

## Big User Stories
### In the below diagram are big user stories for this project. Some are to be completed in the future.
![UserStories](https://user-images.githubusercontent.com/84199502/170409763-c1c44888-cea0-4713-a6ae-e41e30e196a1.png)

## Acknowledgements and Citations
### Storing marker colour in Core Data for Term and Course list item displays
I got the idea to store RGB values from the colour the user selected as a marker colour when creating a new term or course in a Core Data object from this video: https://www.youtube.com/watch?v=kay-B3jWjm8
I implemented it differently than in the video but used the general idea presented in the beginning.

### Other
Other citations and sources are commented where used in the code. Usually for things like iOS bug workarounds, formatting, or minor details. 
