//import papaya.*;
//importing the SimpleOpenNI library
import SimpleOpenNI.*;
import http.requests.*;
SimpleOpenNI kinect;
import processing.video.*;
//


int count=0;
Capture cam;
int camW = 512;
int camH = 128;
int stageW = 1280;
int stageH = 720;
// declaring the angle as global Variable to excess it outside in any other than except Draw Method
float angle_right_arm ;
float angle_left_arm ;

float angle_right_shoulder ;
float angle_left_shoulder ;

//float angle_right_hip ;
//float angle_left_hip ;

float angle_head_neck ;
float angle_bend ;

PrintWriter Pose_interview;
MyThread thread;
int time = millis();
//this value has been obtained by running machine learning algorithm

//float[] weight1 = {
//    0.3234,
//    0.2148,
//   -0.2794,
//   -0.2738,
//   -0.1102,
//    0.0101
//};
//
//float[] weight2 = {
//    0.0789,
//    0.0816,
//    0.0138,
//   -0.0031,
//   -0.0337,
//    0.0088
//};
//
//float[] weight3 = {
//    0.2906,
//    0.2521,
//   -0.1968,
//   -0.2509,
//   -0.0831,
//    0.0061
//};

//float[] weights = {
//  0.50608278,1.22357701,-0.6141514,-2.21387288,-11.61599607,7.04809362
//};
float[] weights = {
 0.19578206, 0.58736465, -1.36231162, -1.05567005, -8.19713737, 2.40257521
};

//float intercept = 34.5867231;
float intercept = 25.38244445;
void setup(){
//     post.addFile("image_file","F:\\sketch_6a\\snap7_0.png");
//     post.send();

//    GetRequest get = new GetRequest("http://192.168.43.223:8000/security/test/");
////    GetRequest get = new GetRequest("https://www.google.com");
////     get.addHeader("Accept", "application/json");
//    get.send();
//    PostRequest post = new PostRequest("http://mscfdsecurityapp.azurewebsites.net/security/image_upload/");
//    post.addHeader("Content-Type", "multipart/form-data"); 
//    post.addFile("image_file","D:\\atm\\code\\sketch_6a\\snap7_1.png");
//post.addData("name", "Suhas");
//    post.send();
//println("Reponse Content: " + post.getContent());
//    println("Reponse Content: " + get.getContent());
    size(640,480,P3D);
    kinect=new SimpleOpenNI(this);
    kinect.enableDepth();
    kinect.enableUser();
    kinect.enableRGB();
    kinect.setMirror(false); 
    Pose_interview = createWriter("normal_home.txt"); 
    textSize(20);
    strokeWeight(5);
//   println(Capture.list());//prints out available cameras
//  webcam = new Capture(this, camW, camH, "FaceTime HD Camera (Built-in)", 10);
//  webcam.start();
//size(640, 480);

  String[] cameras = Capture.list();
//  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[0]);
    cam.start();     
  }    

}

int doubt=0;
int suspect_no = 0;
boolean display = true;
int send = 0;
PostRequest post = new PostRequest("http://mscfdsecurityapp.azurewebsites.net/security/image_upload/");



void draw(){
   cam.read();
   image(cam, 0, 0);
   kinect.update();
   PImage DepthImage = kinect.depthImage();
   image(DepthImage,0,0);

   int[] userList=kinect.getUsers();
   if (userList.length>0){
       int userId=userList[0];
       if(kinect.isTrackingSkeleton(userId)){ 
          //drawSkeleton(userId);
          PVector torso = new PVector();
          PVector leftShoulder = new PVector();
          PVector rightShoulder= new PVector();
          PVector head=new PVector();
          PVector neck =new PVector();
          PVector leftHand = new PVector();
          PVector rightHand = new PVector();
          PVector leftElbow = new PVector();
          PVector rightElbow= new PVector();
          PVector leftHip = new PVector();
          PVector rightHip = new PVector();

          // so we first need to take the origin to the frame of Torso as position of kinect might 
          //disturb the Position of joint relative to it 
         
         float confidence_torso=kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO,torso);
         if (confidence_torso > 0.6) {
            pushMatrix(); 
            // translating the origin
      translate(torso.x,torso.y,torso.z);
            //make upper part of Y axis as positive
            rotateX(radians(180));
            
  //storing Value of shoulder                    
  kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_SHOULDER,leftShoulder);              
  kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER,rightShoulder);
  
  //storing the Value of head and neck
  kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_HEAD,head);
  kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,neck);
  
  //storing the Value of left and Right Hand
  float confidence_left=kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,leftHand);
  float confidence_right=kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,rightHand);
                        
  //storing the Value of leftElbow and RightElbow 
  kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_ELBOW,leftElbow);
  kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,rightElbow);
  
  // next thing would be to compute distance and angle between each Joint
  PVector neckHead, neckleftShoulder, neckrightShoulder, rightShoulder_rightElbow;  
  PVector leftElbow_leftHand, torso_neck, rightElbow_rightHand, leftShoulder_leftElbow;
                         
  // storing the displacment Vector 
                         
  neckHead=PVector.sub(neck,head);
  neckleftShoulder= PVector.sub(neck,leftShoulder);
  neckrightShoulder=PVector.sub(neck,rightShoulder);
  rightShoulder_rightElbow= PVector.sub(rightShoulder,rightElbow);
  rightElbow_rightHand= PVector.sub(rightElbow,rightHand);
  leftShoulder_leftElbow = PVector.sub(leftShoulder,leftElbow);
  leftElbow_leftHand = PVector.sub(leftElbow,leftHand);
  torso_neck  =  PVector.sub(torso,neck);
  
  // in the Paper the main feature which was considered was angle so we need to normalize this vector to calculate the angle
                         
  neckHead.normalize();
  neckleftShoulder.normalize();
  neckrightShoulder.normalize();
  rightShoulder_rightElbow.normalize();
  rightElbow_rightHand.normalize();
  leftShoulder_leftElbow.normalize();
  leftElbow_leftHand.normalize();
  torso_neck.normalize();
  
  // next important thing is to find the angle between joint
  
  //angle of arm 
  angle_right_arm = acos(rightShoulder_rightElbow.dot(rightElbow_rightHand) );
  angle_left_arm = acos( leftShoulder_leftElbow.dot(leftElbow_leftHand) );                         
  
  //angle of Shoulder
  angle_right_shoulder = acos(rightShoulder_rightElbow.dot(neckrightShoulder));
  angle_left_shoulder =  acos(leftShoulder_leftElbow.dot(neckleftShoulder));                     
  
  //the angle of bend and angle between Head and neck
  PVector ref_straight_pos = new PVector(0,1,0);
  angle_bend=acos(torso_neck.dot(ref_straight_pos));
  angle_head_neck = acos(neckHead.dot(torso_neck));
        
  // once all the angle  is calculated next important thing is to calculate the text file for it 
  float [] array_angle = {angle_right_arm , angle_left_arm ,angle_right_shoulder,angle_left_shoulder, angle_bend, angle_head_neck};
  
 
  //moving Data to the Higher Dimension for calculation of output
//  float[] collected_data={1,pow(array_angle[0],2),pow(array_angle[1],3),array_angle[2]*array_angle[3],array_angle[4]*array_angle[5], array_angle[0]*array_angle[1]*array_angle[2]*array_angle[3]*array_angle[4]*array_angle[5]};
  
//    float temp1=0;
//    float temp2=0;
//    float temp3=0;

  float temp=0;
  
//    for (int i=0;i<collected_data.length;i++)
//        {
//        temp1+=weight1[i]*collected_data[i];
//        temp2+=weight2[i]*collected_data[i];
//        temp3+=weight3[i]*collected_data[i];
//        }

  for (int i=0;i<array_angle.length;i++)
  
    {
      temp+=weights[i]*array_angle[i];
    }
    
    temp+=intercept;
         
//       double probability1=1/(1+Math.exp(-1*temp1)); 
//       double probability2=1/(1+Math.exp(-1*temp2));   
//       double probability3=1/(1+Math.exp(-1*temp3));   
//      
//       println("1:"+probability1);
//       println("2:"+probability2);
//       println("3:"+probability3);

    double probability = 1/(1+Math.exp(-1*temp));
       
       popMatrix();
              
//       if(probability1>0.55 || probability2>0.65  || probability1>0.55 ){
//          fill(255,0,0);
//          text("alarm abnormal",int(width/2),int(height/2));
//          }
       // println("prob "+probability);
      
       if(probability>0.955 ){
          
          doubt+=1;
          
          //println(doubt);
          fill(255,0,0);
          text("alarm abnormal",int(width/2),int(height/2));
          
          if(doubt>9)
          {
            doubt=0;
            suspect_no+=1;
            display=false;
            
//            println(display);
//            if (cam.available() == true) {
               
//
////            save("snap"+suspect_no+"_"+2+".png");
////            save("snap"+suspect_no+"_"+3+".png");
////            save("snap"+suspect_no+"_"+4+".png");
            
              if((millis() - 20000) > time)
              {
                time = millis();
                thread =new MyThread();
                println("sending picture");
//                cam.start();
                  cam.read();
                println("taking picture");
                image(cam, 0, 0);
  
  //            save("snap"+suspect_no+"_"+2+".png");
  //            save("snap"+suspect_no+"_"+3+".png");
  //            save("snap"+suspect_no+"_"+4+".png");
                
                 saveFrame("snap7_0"+count+".png");
//                 cam.stop();
                thread.start();
              }
//               save("snap7"+"_"+1+".png");
////              post.addFile("image_file","D:\\atm\\code\\sketch_6a\\snap7_1.png");
////              post.send();
              
           
//              }
             
//           image(kinect.rgbImage(), 0, 0);
//              PostRequest post = new PostRequest("http://mscfdsecurityapp.azurewebsites.net/security/image_upload/");
//               save("snap7"+"_"+1+".png");
//              post.addFile("image_file","D:\\atm\\code\\sketch_6a\\snap7_1.png");
//              post.send();
           
  //          image(webcam,0,0);
  
            display=true;
          }
          }
          else{
          fill(0,255,0);
          text("normal",int(width/2),int(height/2));
          }
          
         drawSkeleton(userId); 
   }  
  }
  }              
}
void captureEvent(Capture webcam)
{
  webcam.read();
}
void drawSkeleton(int userId){
//println(display);
if(display)
{
  stroke(0);
strokeWeight(5);
  drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  
  noStroke();
  fill(0,255,0);
  
  drawJoint(userId,SimpleOpenNI.SKEL_HEAD );
  drawJoint(userId,SimpleOpenNI.SKEL_NECK );
  drawJoint(userId,SimpleOpenNI.SKEL_LEFT_SHOULDER );
  drawJoint(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER);   
  drawJoint(userId,SimpleOpenNI.SKEL_LEFT_ELBOW );
  drawJoint(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawJoint(userId,SimpleOpenNI.SKEL_LEFT_HAND );
  drawJoint(userId,SimpleOpenNI.SKEL_RIGHT_HAND);
  drawJoint(userId,SimpleOpenNI.SKEL_TORSO);
}
}

void drawJoint(int userId,int jointID){
PVector joint =new PVector();
float confidence = kinect.getJointPositionSkeleton(userId,jointID,joint);
        
if (confidence < 0.6){
   return;
   } 
else{
    PVector convertJoint = new PVector();
    kinect.convertRealWorldToProjective(joint,convertJoint);
    ellipse(convertJoint.x,convertJoint.y,5,5);      
    }
}

void drawLimb(int userId,int jointType1,int jointType2)
{
PVector jointPos1 = new PVector();
PVector jointPos2 = new PVector();
float  confidence;
  
// draw the joint position
float confidence1 = kinect.getJointPositionSkeleton(userId,jointType1,jointPos1);
float confidence2 = kinect.getJointPositionSkeleton(userId,jointType2,jointPos2);
  
PVector convertjointPos1=new PVector();
PVector convertjointPos2= new PVector();
kinect.convertRealWorldToProjective(jointPos1,convertjointPos1);
kinect.convertRealWorldToProjective(jointPos2,convertjointPos2);
    
stroke(0);
strokeWeight(5);
if(confidence1>0.6 && confidence2>0.6)
  {
  line(convertjointPos1.x,convertjointPos1.y,
  convertjointPos2.x,convertjointPos2.y);
  }
}

void onNewUser(SimpleOpenNI kinect,int userId)
  {
    println("on NewUser-userId:"+ userId);
    println("\t start tracking Skeleton");
    kinect.startTrackingSkeleton(userId);
  }

void onLostUser(SimpleOpenNI kinect,int userId)
  {
    println("onLostUser - userId: " + userId);
  }

void onVisibleUser(SimpleOpenNI kinect,int userId)
  {
    //println("onVisibleUser - userId: " + userId);
  }

void keyPressed()
{
  println(key);
  switch (key)
  {
  
  //for gesture alarmic 'a' 
  case 'a':
  println(angle_right_arm + " " + angle_left_arm + " " + angle_right_shoulder+" " +angle_left_shoulder +" "+ angle_bend +" "   
   + angle_head_neck + " "+ "1"); 
  Pose_interview.println(angle_right_arm + " " + angle_left_arm + " " + angle_right_shoulder+" " +angle_left_shoulder +" "+ angle_bend +" "   
   + angle_head_neck + " "+ "1");    
  break;

  //for gesture nonalarmic 's' 
 case 's':
  Pose_interview.println(angle_right_arm + " " + angle_left_arm + " " + angle_right_shoulder+" " +angle_left_shoulder + " "+ angle_bend +" " 
   + angle_head_neck + " "+ "0");    
  break;

 /* // for gesture head bend 'd'
  case 'd':
   Pose_interview.println(angle_right_arm + " " + angle_left_arm + " " + angle_right_shoulder+" " +angle_left_shoulder + " "+ angle_bend +" " 
    + angle_head_neck + " "+ "3");    
  break;
  
  // for gesture bending 'f'
  case 'f':
   Pose_interview.println(angle_right_arm + " " + angle_left_arm + " " + angle_right_shoulder+" " +angle_left_shoulder + " "+ angle_bend +" " 
    + angle_head_neck + " "+ "4");    
  break;*/
  
  case 'd':
  //Pose_interview.flush(); // Writes the remaining data to the file
  Pose_interview.close(); // Finishes the file
  exit(); // Stops the program
  break;

  }
}


public class MyThread extends Thread
 {
 
   public void start()
   {
     super.start();
   }
   public void run()
   {
     PostRequest post = new PostRequest("http://mscfdsecurityapp.azurewebsites.net/security/image_upload/");
     println("Inside thread");
     post.addFile("image_file","C:\\Users\\suhas_000\\Documents\\Processing\\sketch_180430a\\snap7_0"+count+".png");
     count++;
     post.send();
     println("Done Posting");
     //send += 1;
      
   }
 }
