## skinMD
skinMD is an iPhone and Android App that analyzes the presence of melanoma or basal cell carcinoma on a user's skin using the phone's camera and a MATLAB image analyis algorithm.

#### Motivation
Skin diseases are one of the most prevalent health problems in the U.S., with rates exceeding even obesity and cancer. For skin-cancers like melanoma, early diagnosis is crucial; the survival rate drops from 95% to 19% as the condition progresses. 

However, dermatologist visits can be costly and time-consuming. If a situation does not seem immediately severe, patients are more likely to avoid seeking medical attention and turn to inaccurate self-assessments.

#### Goals
This project aims to decrease the subjectivity associated with self-assessment by creating a system that allows patients to receive quantitative suggestions about their condition. 

([Melanoma](https://en.wikipedia.org/wiki/Melanoma)) and ([basal cell carcinoma (BCC)](https://en.wikipedia.org/wiki/Basal-cell_carcinoma)) were chosen as targets for a proof of concept as they have well defined features that can be analyzed.


## Algorithm
The image analysis algorithm has two parts: a support vector machine (SVM) and a points-based analysis of 5  features extracted from the images.

#### SVM
([SVMs](https://en.wikipedia.org/wiki/Support_vector_machine)) are a type of supervised learning model used in machine learning to classify a given input. In this case, the models were given a set of images labeled as being healthy or diseased. Thus given a new image, the SVM trained on these labelled images can predict whether a user's skin is healthy or diseased.  Since there are two diseases being addressed, there was one model for melanoma and one for basal cell carcinoma.

#### Feature Extraction
The most common diagnostic technique is the mnemonic ABCDE: A for asymmetric border, B for border irregularity, C for multiple colors, D for diameter greater than 6mm, and E for enlarging or evolving.  E was not addressed in this iteration but could involve saving images per patient and comparing them over time.

Instead, the fifth feature extracted was a histogram of oriented gradients (HoG), a distributation of local intenstity gradients.

##### Edge Detection
A ([Sobel edge detection filter](https://en.wikipedia.org/wiki/Sobel_operator)) was used to extract the lesion's border.  This was used to address A, B, and D in the above memonic.

##### Histogram of Oriented Gradients
The ([histogram of oriented gradients](https://en.wikipedia.org/wiki/Histogram_of_oriented_gradients)) was used as its own feature, which is a distribution of local pixel instensity gradients.  This is another technique to assess border shape and irregularity as the histogram extracts edges and shapes in the image.

##### Color Detection
Lesions have more variations in color compared to healthy skin or benign moles, so the average and standard deviation was calulcated for each of the red, green, and blue color channels.

##### Scoring
A three-column prediction array was used, with one column for melanoma, basal cell carninoma, and healthy skin. The SVM's prediction received one point. To assign points for each of the 5 extracted features, a histogram was created for each feature for each set of training images, melanoma, BCC, and healthy skin.  A point was then given if the user's image fit into the training image's histogram using linear regression.  Finally the column with the most points was the prediction.


## Results
#### Melanoma
##### Sensitivity: 68.17%
##### Specificity: 79.96%

#### Basal Cell Carcinoma
##### Sensitivity: 77.08%
##### Specificity: 97.85%

#### Performance
##### MATLAB Algorithm time: 0.82 +/- 0.01 seconds
##### Phone to server, server to phone: 5.05 +/- 0.44 seconds


## Files
#### iPhone Files
* 
#### MATLAB
*


## Links
* See a short demo on ([YouTube](https://youtu.be/IO3B8MlthmI))
* The app was previously available in the Apple App Store and on Google Play but was removed when server hosting funds were depleated. 
