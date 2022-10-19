void parameter_gui() {
  cp5 = new ControlP5(this);

  // group number 1, contains 2 bangs
  Group g1 = cp5.addGroup("environment parammeter")
    .setBackgroundColor(color(255, 255))
    .setBackgroundHeight(150)
    ;


  Group g2 = cp5.addGroup("Object Graphic")
    .setBackgroundColor(color(255, 255))
    .setBackgroundHeight(200)
    ;

  Group g3 = cp5.addGroup("Motion")
    .setBackgroundColor(color(255, 255))
    .setBackgroundHeight(200)
    ;

  cp5.addSlider("gravity y")
    .setPosition(40, 20)
    .setSize(100, 20)
    .setRange(-200, 200)
    .setValue(0)
    .moveTo(g1);

  cp5.addSlider("resistance")
    .setPosition(40, 60)
    .setSize(100, 20)
    .setRange(-2, 2)
    .setValue(0)
    .moveTo(g1);

  checkbox = cp5.addCheckBox("checkBox")
    .setColorLabel(color(0))
    .setPosition(40, 60)
    .setSize(20, 20)
    .setItemsPerRow(1)
    .setSpacingColumn(30)
    .setSpacingRow(20)
    .addItem("Show particle", 50)
    .addItem("Show object path", 100)
    .addItem("Show object position", 100)
    .moveTo(g2)
    ;

  checkbox1 = cp5.addCheckBox("checkBox1")
    .setColorLabel(color(0))
    .setPosition(40, 40)
    .setSize(20, 20)
    .setItemsPerRow(1)
    .setSpacingColumn(30)
    .setSpacingRow(20)
    .addItem("Object velocity", 0)
    .moveTo(g3)
    ;
  accordion = cp5.addAccordion("acc")
    .setPosition(1600, 40)
    .setWidth(200)
    .addItem(g1)
    .addItem(g2)
    .addItem(g3)
    ;
}
