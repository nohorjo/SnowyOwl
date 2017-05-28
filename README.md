# SnowyOwl
Scans videos and tries to recognise faces.
Uses [OpenFace](https://cmusatyalab.github.io/openface/) face recognition.
## Requirements
- [torch](http://torch.ch/)
- [OpenCV](https://github.com/Itseez/opencv/archive/2.4.11.zip) ([building](http://docs.opencv.org/doc/tutorials/introduction/linux_install/linux_install.html))
- dlib
- nose
- txaio
- pandas
- SciPy
- scikit-learn

## Usage

To use images in _raw_ directory to create the classification model:
```
./prepare.sh
```
To search videos in _vid_ directory:
```
./search.sh
```

