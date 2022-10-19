import oscP5.*;
import netP5.*;
import teilchen.*;
import teilchen.behavior.*;
import teilchen.constraint.*;
import teilchen.cubicle.*;
import teilchen.force.*;
import teilchen.integration.*;
import teilchen.util.*;
import controlP5.*;
import deadpixel.keystone.*;

float backgroundRcolor;
float temp;

Physics mPhysics;

Particle mParticle;
Particle mParticle1;
Particle mParticle2;
Particle mParticle3;
Particle mParticle4;
Particle mParticle5;


ControlP5 cp5;
CheckBox checkbox;
CheckBox checkbox1;

Accordion accordion;

//Keystone
Keystone ks;
CornerPinSurface surface;
PGraphics offscreen;





//for OSC
OscP5 oscP5;
//where to send the commands to
NetAddress[] server;


//we'll keep the cubes here
Cube[] cubes;

int projection_correction = 45;
boolean mouseDrive = false;
boolean chase = false;
boolean spin = false;
boolean drop = false;
boolean projectile = false;
float x_vel;
float y_vel;

CollisionManager mCollision;
Gravity mGravity = new Gravity();
ViscousDrag myViscousDrag;
void settings() {
  size(1000, 1000, P3D);
  fullScreen();
}


void setup() {


  // for OSC
  // receive messages on port 3333
  oscP5 = new OscP5(this, 3333);

  //send back to the BLE interface
  //we can actually have multiple BLE bridges
  server = new NetAddress[1]; //only one for now
  //send on port 3334
  server[0] = new NetAddress("127.0.0.1", 3334);
  //server[1] = new NetAddress("192.168.0.103", 3334);
  //server[2] = new NetAddress("192.168.200.12", 3334);

  mCollision = new CollisionManager();
  mCollision.distancemode(CollisionManager.DISTANCE_MODE_FIXED);
  mCollision.minimumDistance(40);
  //create cubes
  cubes = new Cube[nCubes];
  for (int i = 0; i< cubes.length; ++i) {
    cubes[i] = new Cube(i, true);
  }

  //do not send TOO MANY PACKETS
  //we'll be updating the cubes every frame, so don't try to go too high
  frameRate(50);

  mPhysics = new Physics();

  myViscousDrag = new ViscousDrag();
  myViscousDrag.coefficient = 0;
  mPhysics.add(myViscousDrag);
  /* create a gravitational force */

  /* the direction of the gravity is defined by the 'force' vector */
  mGravity.force().set(0, 0);
  /* forces, like gravity or any other force, can be added to the system. they will be automatically applied to
   all particles */
  mPhysics.add(mGravity);
  /* create a particle and add it to the system */
  mParticle = mPhysics.makeParticle();
  mParticle1 = mPhysics.makeParticle();
  mParticle2 = mPhysics.makeParticle();
  mParticle3 = mPhysics.makeParticle();
  mParticle4 = mPhysics.makeParticle();
  mParticle5 = mPhysics.makeParticle();

  Box myBox = new Box();
  myBox.min().set(100, 100, 0);
  myBox.max().set(600, 400, 0);
  myBox.coefficientofrestitution(0.65f);
  myBox.reflect(true);


  mPhysics.add(myBox);


  //for projections
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(600, 410, 20);

  // We need an offscreen buffer to draw the surface we
  // want projected
  // note that we're matching the resolution of the
  // CornerPinSurface.
  // (The offscreen buffer can be P2D or P3D)
  offscreen = createGraphics(600, 410, P3D);

  parameter_gui();
}

void draw() {
  background(255);
  stroke(0);
  long now = System.currentTimeMillis();

  // change gravity using control p5 slider


  //draw the "mat"
  fill(255);
  rect(45, 45, 410, 410);



  //float s2 = cp5.getController("resistance").getValue();
  //myViscousDrag.coefficient = s2;

  //println(s2);

  int time = 0;
  // toio drop code start
  if (drop) {
    int backgroundCol = 0;
    int strokeCol = 255;


    offscreen.beginDraw();
    offscreen.background(backgroundRcolor, 0, 255-backgroundRcolor);


    final float mDeltaTime = 1.0f / frameRate;
    mCollision.createCollisionResolvers();
    mCollision.loop(mDeltaTime);
    mPhysics.step(mDeltaTime);
    mCollision.removeCollisionResolver();
    mParticle.radius(30);
    mParticle1.radius(30);
    mParticle2.radius(30);
    mParticle3.radius(30);
    mParticle4.radius(30);
    mParticle5.radius(30);
    stroke(255, 255, 0);
    fill(255, 0, 0);


    // draw box
    //line(100, 100, 550, 100);
    //line(550, 100, 550, 400);
    //line(550, 400, 100, 400);
    //line(100, 400, 100, 100);

    offscreen.stroke(255, 255, 255);
    offscreen.line(100 - projection_correction, 100 - projection_correction, 600 - projection_correction, 100 - projection_correction);
    offscreen.line(600 - projection_correction, 100 - projection_correction, 600 - projection_correction, 400 - projection_correction);
    offscreen.line(600 - projection_correction, 400 - projection_correction, 100 - projection_correction, 400 - projection_correction);
    offscreen.line(100 - projection_correction, 400 - projection_correction, 100 - projection_correction, 100 - projection_correction);

    if ((cubes[6].x >= 902 & cubes[6].x <= 938 )& (cubes[6].y >= 260 & cubes[6].y <= 456 )) {
      temp = map(cubes[6].y, 260, 456, -1, 1);
      
      backgroundRcolor = map(temp, -0.28, 1, 255, 52);
      println(temp);
    }

    myViscousDrag.coefficient = temp;

    println(myViscousDrag.coefficient);
    //    String a = "Gravity is: " + gravity_num;
    //    offscreen.textSize(29);
    //    offscreen.text(a, 30, 30);


    // draw particle
    if (checkbox.getArrayValue()[0] == 1) {
      offscreen.fill(strokeCol);
      offscreen.stroke(strokeCol);
      for (int i = 0; i < cubes.length; ++i) {
        if (cubes[i].isLost==false) {
          offscreen.ellipse(mParticle.position().x - projection_correction, mParticle.position().y - projection_correction, 40, 40);
          offscreen.ellipse(mParticle1.position().x - projection_correction, mParticle1.position().y - projection_correction, 40, 40);
          offscreen.ellipse(mParticle2.position().x - projection_correction, mParticle2.position().y - projection_correction, 40, 40);
          offscreen.ellipse(mParticle3.position().x - projection_correction, mParticle3.position().y - projection_correction, 40, 40);
          offscreen.ellipse(mParticle4.position().x - projection_correction, mParticle4.position().y - projection_correction, 40, 40);
          offscreen.ellipse(mParticle5.position().x - projection_correction, mParticle5.position().y - projection_correction, 40, 40);
        }
      }
    }
    // draw path
    if (checkbox.getArrayValue()[1] == 1) {
      offscreen.fill(50, 82, 200);
      offscreen.stroke(50, 82, 200);
      for (int i = 0; i < cubes.length; ++i) {
        for (int j = 0; j < cubes[i].aveFrameNumPosition; j++) {

          offscreen.ellipse(cubes[i].cube_position_x[j] - projection_correction, cubes[i].cube_position_y[j] - projection_correction, 2, 2);
        }
      }
    }
    //draw the cubes
    if (checkbox.getArrayValue()[2] == 1 ) {

      for (int i = 0; i < cubes.length; ++i) {
        if (cubes[i].isLost==false) {
          offscreen.pushMatrix();
          offscreen.fill(backgroundCol);
          offscreen.stroke(strokeCol);
          offscreen.translate(cubes[i].x - projection_correction, cubes[i].y - projection_correction);
          offscreen.rotate(cubes[i].deg * PI/180);
          offscreen.rect(-10, -10, 20, 20);
          offscreen.rect(0, -5, 20, 10);
          offscreen.popMatrix();
        }
      }
    }

    if (checkbox1.getArrayValue()[0] == 1) {
      // draw velocity vector



      for (int i = 0; i < cubes.length; ++i) {
        if (cubes[i].isLost==false) {
          offscreen.pushMatrix();
          offscreen.translate(cubes[i].x, cubes[i].y);
          offscreen.stroke(195, 155, 211);
          drawArrow(0, 0, cubes[i].ave_speedX, cubes[i].ave_speedY, 0);
          offscreen.popMatrix();
        }
      }
    }


    String a = "Temperature is: " + backgroundRcolor + "K";
    offscreen.fill(strokeCol);
    offscreen.stroke(strokeCol);
    offscreen.textSize(29);
    offscreen.text(a, 30, 30);

    offscreen.endDraw();

    background(0);
    // render the scene, transformed using the corner pin surface
    surface.render(offscreen);

    // -----------------------------------------
    // first particle
    if (cubes[0].isLost == true) {

      cubes[0].state = 1;
    }

    if (cubes[0].isLost==false) {

      if (cubes[0].state == 1) {
        cubes[0].origin_x = cubes[0].x;
        cubes[0].origin_y = cubes[0].y;
        cubes[0].state += 1;
      }
      //println(cubes[i].origin_x + " " + cubes[i].origin_y);
      //println(cubes[i].state);


      //println(dist(cubes[i].origin_x, cubes[i].origin_y, cubes[i].x, cubes[i].prey) > 60 && dist(cubes[i].origin_x, cubes[i].origin_y, cubes[i].x, cubes[i].y) > 60);
      //println(cubes[i].state);
      boolean condition = dist(cubes[0].origin_x, cubes[0].origin_y, cubes[0].x, cubes[0].prey) > 60 && dist(cubes[0].origin_x, cubes[0].origin_y, cubes[0].x, cubes[0].y) > 60;
      if ((condition == true && cubes[0].state == 2)) {
        cubes[0].state += 1;

        mParticle.position().set(cubes[0].x, cubes[0].y);
        mParticle.velocity().set(cubes[0].speedX/11, cubes[0].speedY/11);
        mCollision.collision().add(mParticle);
      }


      if (cubes[0].state > 2 ) {


        aimCubePosVel(cubes[0].id, mParticle.position().x, mParticle.position().y, mParticle.velocity().y, mParticle.velocity().x);
        println("vel is: ", mParticle.velocity().y);
        //print("state 3 triggered!");
      }
    }

    // second particle

    if (cubes[1].isLost == true) {

      cubes[1].state = 1;
    }

    if (cubes[1].isLost==false) {

      if (cubes[1].state == 1) {
        cubes[1].origin_x = cubes[1].x;
        cubes[1].origin_y = cubes[1].y;
        cubes[1].state += 1;
      }
      //println(cubes[i].origin_x + " " + cubes[i].origin_y);
      //println(cubes[i].state);


      //println(dist(cubes[i].origin_x, cubes[i].origin_y, cubes[i].x, cubes[i].prey) > 60 && dist(cubes[i].origin_x, cubes[i].origin_y, cubes[i].x, cubes[i].y) > 60);
      //println(cubes[i].state);
      boolean condition = dist(cubes[1].origin_x, cubes[1].origin_y, cubes[1].x, cubes[1].prey) > 60 && dist(cubes[1].origin_x, cubes[1].origin_y, cubes[1].x, cubes[1].y) > 60;
      if ((condition == true && cubes[1].state == 2)) {
        cubes[1].state += 1;

        mParticle1.position().set(cubes[1].x, cubes[1].y);
        mParticle1.velocity().set(cubes[1].speedX/11, cubes[1].speedY/11);
        mCollision.collision().add(mParticle1);
      }




      aimCubePosVel(cubes[1].id, mParticle1.position().x, mParticle1.position().y, mParticle1.velocity().y, mParticle1.velocity().x);

      //print("state 3 triggered!");
    }


    // third particle

    if (cubes[2].isLost == true) {

      cubes[2].state = 1;
    }

    if (cubes[2].isLost==false) {

      if (cubes[2].state == 1) {
        cubes[2].origin_x = cubes[2].x;
        cubes[2].origin_y = cubes[2].y;
        cubes[2].state += 1;
      }
      //println(cubes[i].origin_x + " " + cubes[i].origin_y);
      //println(cubes[i].state);


      //println(dist(cubes[i].origin_x, cubes[i].origin_y, cubes[i].x, cubes[i].prey) > 60 && dist(cubes[i].origin_x, cubes[i].origin_y, cubes[i].x, cubes[i].y) > 60);
      //println(cubes[i].state);
      boolean condition = dist(cubes[2].origin_x, cubes[2].origin_y, cubes[2].x, cubes[2].prey) > 60 && dist(cubes[2].origin_x, cubes[2].origin_y, cubes[2].x, cubes[2].y) > 60;
      if ((condition == true && cubes[2].state == 2)) {
        cubes[2].state += 1;

        mParticle2.position().set(cubes[2].x, cubes[2].y);
        mParticle2.velocity().set(cubes[2].speedX/11, cubes[2].speedY/11);
        mCollision.collision().add(mParticle2);
      }


      if (cubes[2].state > 2 ) {


        aimCubePosVel(cubes[2].id, mParticle2.position().x, mParticle2.position().y, mParticle2.velocity().y, mParticle2.velocity().x);

        //print("state 3 triggered!");
      }
    }
    // fourth particle

    if (cubes[3].isLost == true) {

      cubes[3].state = 1;
    }

    if (cubes[3].isLost==false) {

      if (cubes[3].state == 1) {
        cubes[3].origin_x = cubes[3].x;
        cubes[3].origin_y = cubes[3].y;
        cubes[3].state += 1;
      }
      //println(cubes[i].origin_x + " " + cubes[i].origin_y);
      //println(cubes[i].state);


      //println(dist(cubes[i].origin_x, cubes[i].origin_y, cubes[i].x, cubes[i].prey) > 60 && dist(cubes[i].origin_x, cubes[i].origin_y, cubes[i].x, cubes[i].y) > 60);
      //println(cubes[i].state);
      boolean condition = dist(cubes[3].origin_x, cubes[3].origin_y, cubes[3].x, cubes[3].prey) > 60 && dist(cubes[3].origin_x, cubes[3].origin_y, cubes[3].x, cubes[3].y) > 60;
      if ((condition == true && cubes[3].state == 2)) {
        cubes[3].state += 1;

        mParticle3.position().set(cubes[3].x, cubes[3].y);
        mParticle3.velocity().set(cubes[3].speedX/11, cubes[3].speedY/11);
        mCollision.collision().add(mParticle3);
      }


      if (cubes[3].state > 2 ) {


        aimCubePosVel(cubes[3].id, mParticle3.position().x, mParticle3.position().y, mParticle3.velocity().y, mParticle3.velocity().x);

        //print("state 3 triggered!");
      }
    }
    //  fifth particle
    if (cubes[4].isLost == true) {

      cubes[4].state = 1;
    }

    if (cubes[4].isLost==false) {

      if (cubes[4].state == 1) {
        cubes[4].origin_x = cubes[4].x;
        cubes[4].origin_y = cubes[4].y;
        cubes[4].state += 1;
      }
      //println(cubes[i].origin_x + " " + cubes[i].origin_y);
      //println(cubes[i].state);


      //println(dist(cubes[i].origin_x, cubes[i].origin_y, cubes[i].x, cubes[i].prey) > 60 && dist(cubes[i].origin_x, cubes[i].origin_y, cubes[i].x, cubes[i].y) > 60);
      //println(cubes[i].state);
      boolean condition = dist(cubes[4].origin_x, cubes[4].origin_y, cubes[4].x, cubes[4].prey) > 60 && dist(cubes[4].origin_x, cubes[4].origin_y, cubes[4].x, cubes[4].y) > 60;
      if ((condition == true && cubes[4].state == 2)) {
        cubes[4].state += 1;

        mParticle4.position().set(cubes[4].x, cubes[4].y);
        mParticle4.velocity().set(cubes[4].speedX/11, cubes[4].speedY/11);
        mCollision.collision().add(mParticle4);
      }


      if (cubes[4].state > 2 ) {


        aimCubePosVel(cubes[4].id, mParticle4.position().x, mParticle4.position().y, mParticle4.velocity().y, mParticle4.velocity().x);

        //print("state 3 triggered!");
      }
    }

    //  sixth particle
    if (cubes[5].isLost == true) {

      cubes[5].state = 1;
    }

    if (cubes[5].isLost==false) {

      if (cubes[5].state == 1) {
        cubes[5].origin_x = cubes[5].x;
        cubes[5].origin_y = cubes[5].y;
        cubes[5].state += 1;
      }
      //println(cubes[i].origin_x + " " + cubes[i].origin_y);
      //println(cubes[i].state);


      //println(dist(cubes[i].origin_x, cubes[i].origin_y, cubes[i].x, cubes[i].prey) > 60 && dist(cubes[i].origin_x, cubes[i].origin_y, cubes[i].x, cubes[i].y) > 60);
      //println(cubes[i].state);
      boolean condition = dist(cubes[5].origin_x, cubes[5].origin_y, cubes[5].x, cubes[5].prey) > 60 && dist(cubes[5].origin_x, cubes[5].origin_y, cubes[5].x, cubes[5].y) > 60;
      if ((condition == true && cubes[5].state == 2)) {
        cubes[5].state += 1;

        mParticle5.position().set(cubes[5].x, cubes[5].y);
        mParticle5.velocity().set(cubes[5].speedX/11, cubes[5].speedY/11);
        mCollision.collision().add(mParticle5);
      }


      if (cubes[5].state > 2 ) {


        aimCubePosVel(cubes[5].id, mParticle5.position().x, mParticle5.position().y, mParticle5.velocity().y, mParticle5.velocity().x);

        //print("state 3 triggered!");
      }
    }
  }

  // toio drop code end




  if (chase) {
    cubes[0].targetx = cubes[0].x;
    cubes[0].targety = cubes[0].y;
    cubes[1].targetx = cubes[0].x;
    cubes[1].targety = cubes[0].y;
  }
  //makes a circle with n cubes
  if (mouseDrive) {
    float mx = (mouseX);
    float my = (mouseY);
    float cx = 45+410/2;
    float cy = 45+410/2;

    float mulr = 180.0;

    float aMouse = atan2( my-cy, mx-cx);
    float r = sqrt ( (mx - cx)*(mx-cx) + (my-cy)*(my-cy));
    r = min(mulr, r);
    for (int i = 0; i< nCubes; ++i) {
      if (cubes[i].isLost==false) {
        float angle = TWO_PI*i/nCubes;
        float na = aMouse+angle;
        float tax = cx + r*cos(na);
        float tay = cy + r*sin(na);
        fill(255, 0, 0);
        ellipse(tax, tay, 10, 10);
        cubes[i].targetx = tax;
        cubes[i].targety = tay;
      }
    }
  }

  if (spin) {
    motorControl(0, -100, 100, 30);
  }

  if (chase || mouseDrive) {
    //do the actual aim
    for (int i = 0; i< nCubes; ++i) {
      if (cubes[i].isLost==false) {
        fill(0, 255, 0);
        ellipse(cubes[i].targetx, cubes[i].targety, 10, 10);
        aimCubeSpeed(i, cubes[i].targetx, cubes[i].targety);
      }
    }
  }


  //did we lost some cubes?
  for (int i=0; i<nCubes; ++i) {
    // 500ms since last update
    cubes[i].p_isLost = cubes[i].isLost;
    if (cubes[i].lastUpdate < now - 1500 && cubes[i].isLost==false) {
      cubes[i].isLost= true;
    }
  }
}




void keyPressed() {
  switch(key) {
  case 'q':
    projectile = true;
    break;

  case 'c':
    // enter/leave calibration mode, where surfaces can be warped
    // and moved
    ks.toggleCalibration();
    break;
  case 'd':
    drop = true;
    chase = false;
    spin = false;
    mouseDrive = false;
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;

  case 'a':
    for (int i=0; i < nCubes; ++i) {
      aimMotorControl(i, 380, 260);
    }
    break;
  case 'k':
    light(0, 100, 255, 0, 0);
    break;
  default:
    break;
  }
}


void drawArrow(float x1, float y1, float x2, float y2, int i) {
  if (cubes[i].isLost==false) {
    float a = dist(x1, y1, x2, y2) / 50;
    offscreen.pushMatrix();
    offscreen.translate(x2 - projection_correction, y2- projection_correction);
    offscreen.rotate(atan2(y2 - y1, x2 - x1));
    offscreen.triangle(- a * 2, - a, 0, 0, - a * 2, a);
    offscreen.popMatrix();
    offscreen.line(x1- projection_correction, y1- projection_correction, x2- projection_correction, y2- projection_correction);
  }
}
