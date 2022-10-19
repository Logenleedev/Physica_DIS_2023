

void setup_grab_release() {
  println("triggered!");
  /* create a particle system */
  mPhysics = new Physics();
  /* create a viscous force that slows down all motion; 0 means no slowing down. */
  ViscousDrag myDrag = new ViscousDrag(0.5f);
  mPhysics.add(myDrag);
  /* create two particles that we can connect with a spring */
  myA = mPhysics.makeParticle();
  myA.position().set(width / 3.0f - 100, height / 3.0f);
  myB = mPhysics.makeParticle();
  myB.position().set(width / 3.0f - 150, height / 3.0f);
  /* create a spring force that connects two particles.
   * note that there is more than one way to create a spring.
   * in our case the restlength of the spring is defined by the
   * particles current position.
   */
  myA.fixed(true);
  mSpring = mPhysics.makeSpring(myA, myB);
  mSpring.setOneWay(true);

  mParticle = mPhysics.makeParticle();


  /* create a gravitational force */

  /* the direction of the gravity is defined by the 'force' vector */
  mGravity.force().set(0, 50);
  /* forces, like gravity or any other force, can be added to the system. they will be automatically applied to
   all particles */
  mPhysics.add(mGravity);
}

void grab_release() {
  /* update the particle system */
  final float mDeltaTime = 1.0f / frameRate;
  mPhysics.step(mDeltaTime);


  if (cubes[0].isLost==false && cubes[0].pre_press == 0 && cubes[0].press == 128) {
    mSpring.a().position().set(cubes[0].x, cubes[0].y);
  }


  println(mSpring.strength());




  // draw history path
  if (checkbox2.getArrayValue()[2] == 1) {
    offscreen.fill(50, 82, 200);
    offscreen.stroke(50, 82, 200);
    for (int j = 0; j < cubes[0].aveFrameNumPosition; j++) {

      offscreen.ellipse(cubes[0].cube_position_x[j] - projection_correction, cubes[0].cube_position_y[j] - projection_correction, 2, 2);
    }
  }


  if (checkbox3.getArrayValue()[0] == 1) {
    // draw velocity vector
    offscreen.pushMatrix();
    offscreen.translate(cubes[0].x, cubes[0].y);
    offscreen.stroke(195, 155, 211);
    drawArrow(0, 0, cubes[0].ave_speedX, cubes[0].ave_speedY, 0);
    offscreen.popMatrix();
  }

  if (checkbox3.getArrayValue()[1] == 1) {
    // draw mParticle vector
    offscreen.pushMatrix();
    offscreen.translate(cubes[0].x, cubes[0].y);
    offscreen.stroke(248, 196, 113);
    drawArrow(0, 0, mParticle.velocity().x - projection_correction, mParticle.velocity().y - projection_correction, 0);
    offscreen.popMatrix();
  }
  if (cubes[0].isLost == true) {
    cubes[0].pre_press = 0;
    cubes[0].press = 0;
    cubes[0].state = 1;
    // draw spring
    if (checkbox2.getArrayValue()[0] == 1 ) {
      offscreen.stroke(255, 255, 255);
      offscreen.fill(255, 255, 255);

      offscreen.ellipse(mSpring.a().position().x - projection_correction, mSpring.a().position().y - projection_correction, 5, 5);
      offscreen.line(mSpring.a().position().x - projection_correction, mSpring.a().position().y - projection_correction,
        mSpring.b().position().x - projection_correction, mSpring.b().position().y - projection_correction);
    }
  }





  if (cubes[0].isLost==false && cubes[0].p_isLost == true) {
    mSpring.b().position().set(cubes[0].x, cubes[0].y);
  }
  if (cubes[0].isLost==false) {
    cubes[0].pre_spring_length = cubes[0].current_spring_length;
    cubes[0].current_spring_length = mSpring.currentLength();
    offscreen.stroke(255, 255, 255);
    offscreen.fill(255, 255, 255);
    offscreen.ellipse(mSpring.a().position().x - projection_correction, mSpring.a().position().y - projection_correction, 5, 5);
    offscreen.line(mSpring.a().position().x - projection_correction, mSpring.a().position().y - projection_correction,
      mSpring.b().position().x - projection_correction, mSpring.b().position().y - projection_correction);

    //println(cubes[i].state);

    if (cubes[0].pre_press == 0 && cubes[0].press == 128 ) {
      mSpring.a().position().set(cubes[0].x, cubes[0].y);
      cubes[0].pre_spring_length = 10;
    }

    // anchor changing code
    if (cubes[0].current_spring_length < 50 && cubes[0].pre_spring_length < 50) {
      // draw spring
      println("Hello!");
      if (checkbox2.getArrayValue()[0] == 1 ) {
        // Spring and anchor
        offscreen.stroke(255, 255, 255);
        offscreen.fill(255, 255, 255);

        offscreen.ellipse(mSpring.a().position().x - projection_correction, mSpring.a().position().y - projection_correction, 5, 5);
      }

      aimCubePosVel(cubes[0].id, mSpring.b().position().x, mSpring.b().position().y, mSpring.b().velocity().x, mSpring.b().velocity().y);
      //if ( eventDetection(cubes[0].x, cubes[0].y, cubes[0].prex, cubes[0].prey, cubes[0].speedX, cubes[0].speedY) ) {
      //  mSpring.b().position().set(cubes[0].x, cubes[0].y);
      //}
    }

    // slingshot release code
    if (cubes[0].current_spring_length > 50 && cubes[0].state == 1) {



      aimCubePosVel(cubes[0].id, mSpring.b().position().x, mSpring.b().position().y, mSpring.b().velocity().x, mSpring.b().velocity().y);
      if ( eventDetection(cubes[0].x, cubes[0].y, cubes[0].prex, cubes[0].prey, cubes[0].speedX, cubes[0].speedY) ) {
        mSpring.b().position().set(cubes[0].x, cubes[0].y);
      }
    }

    if (cubes[0].pre_spring_length > 50 && cubes[0].current_spring_length < 50 && cubes[0].state == 1) {
      //println("2 count is:" + count);
 
      mParticle.position().set(mSpring.b().position().x, mSpring.b().position().y);
      mParticle.velocity().set(mSpring.b().velocity().x, mSpring.b().velocity().y);

      cubes[0].state += 1;
    }

    if (cubes[0].state >= 2 ) {


      aimCubePosVel(cubes[0].id, mParticle.position().x, mParticle.position().y, mParticle.velocity().x, mParticle.velocity().y);
      cubes[0].state += 1;
    }

    //draw particle
    if (checkbox2.getArrayValue()[1] == 1) {
      offscreen.stroke(255, 255, 255);
      offscreen.fill(255, 255, 255);
      offscreen.ellipse(mParticle.position().x - projection_correction, mParticle.position().y - projection_correction, 15, 15);
    }
  }
}
