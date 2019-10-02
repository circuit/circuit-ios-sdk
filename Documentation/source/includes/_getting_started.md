# Getting Started

Before we can start building an application we need to install CircuitSDK to the your project.

## Installing CocoaPods

First of all, make sure you have [CocoaPods](https://cocoapods.org/) installed on your system.

To install CocoaPods make sure you have latest Xcode,
open the terminal and run the
following command below:

**`sudo gem install cocoapod`**

## Setting up CocoaPods

For the CircuitSDK to run properly, you must setup your project with CocoaPods.
In the terminal navigate to your project folder and run the command below:

**`pod init`**

pod init sets up a PodFile for your project

The file should look like this where PROJECT NAME is your project name

![](/images/podfile.png)

## Installing CircuitSDK

Once CocoaPods is installed you are ready to add and install the pod CircuitSDK

Open your Podfile in Xcode, do not use TextEdit as TextEdit uses smart quotes
which will generate errors upon trying to install the pod

Under target 'PROJECT NAME' (is your project name) add the following

`pod 'CircuitSDK'`

This tells CocoaPods you want to use the CircuitSDK pod with your project,
save the Podfile.

Your Podfile should look like the example below

![](/images/circuitsdk.png)

Now in the terminal navigate to your project folder containing the Podfile, run
the command below to install the CircuitSDK pod:

**`pod install`**

The cocoaPods will download the latest CircuitSDK with the related dependencies.

Lastly get the WebRTC dependency (Source/libCKTNavigator.a).

Simply from project repo run in terminal:

`curl -X GET -o "Source/libCKTNavigator.a" "https://www.googleapis.com/storage/v1/b/circuit-ios-sdk/o/lib`

CircuitSDK uses [SocketRocket](https://github.com/facebook/SocketRocket) pod






