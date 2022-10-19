boolean eventDetection(float cube_x, float cube_y, float particle_x, float particle_y, float vx, float vy){
  
  float velocity = sqrt(sq(vx)+sq(vy));
  //println("velocity is: "+velocity);
  //println("distance is: "+dist(cube_x, cube_y, particle_x, particle_y));
  

  if ((dist(cube_x, cube_y, particle_x, particle_y) > 8) ){
    
    return false;
  } else {
    
    return true;
  }
  
  //return true;
}
