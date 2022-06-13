#  GradeTracker

## About GradeTracker
GradeTracker is a program that aims to simplify the student experience by allowing a user to manage courses and syllabus items by entering a "goal" grade for a course, and the program can then calculate and display a target grade which the student will need to achieve on syllabus items to meet that goal grade in the course. The target grade adjusts as necessary when final grades are assigned to syllabus items, or if the weight or final grade is adjusted for any syllabus item.
The visual component of progress towards a goal grade as well as exact figures in terms of criteria necessary to achieve the goal can hopefully empower and motivate students.

## Big User Stories
### In the below diagram are big user stories for this project. Some are to be completed in the future.
![UserStories](https://user-images.githubusercontent.com/84199502/170409763-c1c44888-cea0-4713-a6ae-e41e30e196a1.png)

## Packages and Major Source Code Organization 
### The code is organized at present into "Model" and "View" and will soon have "ViewModel" introduced. 
Model contains the logic and Core Data files, while View contains UI files. ViewModel will contain files/code that behave as intermediaries, to ensure that the Model and the View code can more safely interact -- ie. will contain business logic.

### Built With
#### Development Environment: XCode
#### Languages: Swift, SwiftUI
#### Persistence Framework: Core Data

## Usage and Demo Videos
### Adding A Term
#### The user may add a term name, start and end dates, and choose a marker colour.
The terms will display in a list on the main page, with the most recent start date at the top (they are ordered from most to least recent start date).
The user can edit these attributes in the term's main page, which is accessed by selecting the term from the main page.

https://user-images.githubusercontent.com/84199502/173445037-b3912566-4b73-4064-a985-209dcce22790.mov

### Adding A Course To A Term
#### The user may add a course name and a goal grade.
These attributes can be edited in the course's main page, which is accessed by selecting the course from the term's page.

https://user-images.githubusercontent.com/84199502/170411504-cd6474ad-6e9c-4af8-a90b-f214fb02ecab.mov

### Adding A Syllabus Item To A Course
#### The user may add a syllabus item name, it's weight (percentage of the course it's worth), it's due date and time, and optionally a final grade (this can be added later)
These attributes can be edited by selecting the syllabus item when it's displayed on the course page.
#### NOTE: The target grade for syllabus items will not be displayed until the sum of weights total 100% or more. In other words, until all syllabus items are added. See demo video below (adding final grade to syllabus item) to view how the target grade is displayed once all syllabus items are added.

https://user-images.githubusercontent.com/84199502/170411831-bd585d9f-c1cf-42e4-95da-8018e28e6609.mov

### Adding Final Grade To Syllabus Item
#### If the Syllabus Item was added without an initial grade, one can be added by selecting the item in the list. Once the final grade is added for that item, it's display will change to show a progress bar and the percentage achieved, and the target grade will adjust accordingly for subsequent un-marked syllabus items. 

https://user-images.githubusercontent.com/84199502/170412142-9f9d0638-2e8f-4c2b-9d75-0796980af9e7.mov

## Testing
Tests have been written for the Course class so far, and more tests will be added (UI tests). The main functionality of correctly calculating the target grade for syllabus items in a course has been tested in the CourseTests class.

## Acknowledgements and Citations
### Storing marker colour in Core Data for Term and Course list item displays
I got the idea to store RGB values from the colour the user selected as a marker colour when creating a new term or course in a Core Data object from this video: https://www.youtube.com/watch?v=kay-B3jWjm8
I implemented it differently than in the video but used the general idea presented in the beginning.

### Other
Other citations and sources are commented where used in the code. Usually for things like iOS bug workarounds, formatting, or minor details. 
