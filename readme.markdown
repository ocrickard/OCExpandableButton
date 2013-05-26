#OCExpandableButton#

<p align="center"><img src="https://raw.github.com/rnystrom/OCExpandableButton/master/animation.gif"/></p>

##Intro##

OCExpandableButton is a VERY simple component in native Objective C that mimics the behavior of the expanding menu in the Sparrow mail app.  You give it an array of subviews, and it presents them when it's activated.  It is a normal subview, so you're in charge of rotation, and anything extra.

##Usage##

Usage of the control is totally simple, it works just like any other UIView:

```objc
button = [[OCExpandableButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 57, self.view.bounds.size.height - 57, 37, 37) subviews:subviews];
[self.view addSubview:button];
```

The array of subviews will be positioned and aligned upon opening of the control.  The frame for the control should be a square region.  The blue "arrow" button will be inset by 4 pixels from this initial rect.

If you want to manually open/close the component (say the screen rotates, or the user begins to scroll), then you can use the following methods:

```objc
//Opens the control if the control is currently closed.  No effect if the button
// is already open.
- (void)open;

//Closes the control if open.  No effect if already closed.
- (void)close;
```

You can make the component reveal with left or right alignment using:
```objc
button.alignment = OCExpandableButtonAlignmentLeft;
```
or
```objc
button.alignment = OCExpandableButtonAlignmentRight;
```

TODO:

- Implement inner shadows like they have in Sparrow - Not sure what the right API looks like here.  Maybe just letting user specify images, or maybe using masks and drawing inner shadows manually?
- Suggestions?
