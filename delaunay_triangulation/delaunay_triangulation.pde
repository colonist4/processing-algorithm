import java.util.LinkedList;
import java.util.Stack;

final static int INF = 20000;
final static int numVertex = 50;

ArrayList<Triangle> triangles;
ArrayList<Vertex> vertices;
Stack<Edge> edgeStack;

Triangle pseudoTriangle;

void setup(){
  size(1000, 800);
  frameRate(60);
  
  triangles = new ArrayList<Triangle>();
  vertices = new ArrayList<Vertex>();
  edgeStack = new Stack<Edge>();
  
  pseudoTriangle = new Triangle();
  pseudoTriangle.vertices[0] = new Vertex(width/2, -INF);
  pseudoTriangle.vertices[1] = new Vertex(-INF, INF);
  pseudoTriangle.vertices[2] = new Vertex(INF, INF);
  //pseudoTriangle.vertices[0] = new Vertex(250, 0);
  //pseudoTriangle.vertices[1] = new Vertex(0, 500);
  //pseudoTriangle.vertices[2] = new Vertex(500, 500);
  pseudoTriangle.setPseudo();
  pseudoTriangle.createEdges();
  
  //vertices.add(new Vertex(150, 250));
  //vertices.add(new Vertex(250, 250));
  //vertices.add(new Vertex(350, 250));
  
  //vertices.add(new Vertex(350, 400));
  //vertices.add(new Vertex(250, 400));
  //vertices.add(new Vertex(150, 400));
  for(int i=0; i<numVertex; i++){
    Vertex v = new Vertex(random(0, width), random(0, height));
    v.velocity = PVector.random2D().mult(random(1, 10));
    vertices.add(v);
  }
}

void draw(){ //<>//
  //background(0);
  fill(0, 100);
  rect(0, 0, width, height);
  
  findDT();
  drawVertices();
  drawEdgesExceptPseudo();
  for(Vertex v: vertices)
    v.update();
  
  textSize(16);
  textAlign(LEFT, TOP);
  fill(255, 0, 0);
  text(frameRate, 10, 10);
}

void drawAllEdges(){
  for(Triangle t_: triangles){
    for(int i=0; i<3; i++){
      Edge e = t_.edges[i];
      line(e.vertices[0].position.x, e.vertices[0].position.y, e.vertices[1].position.x, e.vertices[1].position.y);
    }
  }
}

void drawVertices(){
  stroke(255);
  fill(255);
  for(Vertex v : vertices){
    if(!v.isPseudo){
      ellipse(v.position.x, v.position.y, 4, 4);
    }
  }
}

void drawEdgesExceptPseudo(){
  stroke(255, 50);
  for(Triangle t_: triangles){
    for(int i=0; i<3; i++){
      Edge e = t_.edges[i];
      if(e.isPseudo) continue;
      line(e.vertices[0].position.x, e.vertices[0].position.y, e.vertices[1].position.x, e.vertices[1].position.y);
    }
  }
}

Triangle findIncludeTriangle(Vertex s){
  for(Triangle t : triangles){
    int i = 0;
    for(; i<3; i++){
      PVector v1 = t.edges[i].e;
      PVector v2 = PVector.sub(s.position, t.edges[i].vertices[1].position);
      if(CCW(v1, v2) > 0)
        break;
    }
    if(i == 3){
      return t;
    }
  }
  return null;
}

float CCW(PVector v1, PVector v2){
  return v1.x*v2.y - v1.y*v2.x;
}
 //<>//
void makeThreeTriangle(Vertex s, Triangle t){
  Triangle newTs[] = new Triangle[3];
  
  for(int i=0; i<3; i++){
    Vertex v1 = t.vertices[i];
    Vertex v2 = t.vertices[(i+1)%3];
    
    Triangle newT = new Triangle();
    newT.vertices[0] = v1;
    newT.vertices[1] = v2;
    newT.vertices[2] = s;
    newT.createEdges();
    
    newTs[i] = newT;
    
    triangles.add(newT);
    
    edgeStack.add(newT.edges[0]);
  }
  
  for(int i=0; i<3; i++){
    newTs[i].edges[0].right = t.edges[i].right;
    newTs[i].edges[1].right = newTs[(i+1)%3];
    newTs[i].edges[2].right = newTs[(i+2)%3];
    
    setRightTriangle(newTs[i].edges[0]);
  }
  
  t.removeEdges();
  
  triangles.remove(t);
}

boolean lawsonFlip(Edge e){
  if(e.isDeleted) return false;
  
  Triangle left = e.left;
  Triangle right = e.right;
  
  // 최외각 삼각형일때.
  if(right == null) return false;
  
  int rIndex=0, lIndex=0;
  
  float cosA = 0, cosB = 0;
  for(int i=0; i<3; i++){
    if(left.vertices[i] != e.vertices[0] &&
      left.vertices[i] != e.vertices[1]){
        lIndex = i;
        
        PVector el1 = left.edges[i].e.copy();
        PVector el2 = left.edges[(i+2)%3].e.copy();
        el1.normalize();
        el2.normalize();
        
        cosA = -el1.dot(el2);
        
        break;
      }
  }
  
  for(int i=0; i<3; i++){
    if(right.vertices[i] != e.vertices[0] &&
      right.vertices[i] != e.vertices[1]){
        rIndex = i;
        
        PVector er1 = right.edges[i].e.copy();
        PVector er2 = right.edges[(i+2)%3].e.copy();
        er1.normalize();
        er2.normalize();
        
        cosB = -er1.dot(er2);
        
        break;
      }
  }
  
  // 외부
  if(cosB > -cosA)
    return false;
  
  // 내부
  // Flip
  Triangle tA = new Triangle();
  tA.vertices[0] = left.vertices[lIndex];
  tA.vertices[1] = right.vertices[rIndex];
  tA.vertices[2] = right.vertices[(rIndex+1)%3];
  tA.createEdges();
  
  Triangle tB = new Triangle();
  tB.vertices[0] = right.vertices[rIndex];
  tB.vertices[1] = left.vertices[lIndex];
  tB.vertices[2] = left.vertices[(lIndex+1)%3];
  tB.createEdges();
  
  tA.edges[0].right = tB;
  tB.edges[0].right = tA;
  
  tA.edges[1].right = right.edges[rIndex].right;
  tB.edges[1].right = left.edges[lIndex].right;
  
  tA.edges[2].right = left.edges[(lIndex+2)%3].right;
  tB.edges[2].right = right.edges[(rIndex+2)%3].right;
  
  setRightTriangle(tA.edges[1]);
  setRightTriangle(tB.edges[1]);
  
  setRightTriangle(tA.edges[2]);
  setRightTriangle(tB.edges[2]);
  
  edgeStack.push(right.edges[rIndex]);
  edgeStack.push(right.edges[(rIndex+2)%3]);
  
  left.removeEdges();
  right.removeEdges();
  
  triangles.remove(left);
  triangles.remove(right);
  
  triangles.add(tA);
  triangles.add(tB);
  
  return true;  
}

void setRightTriangle(Edge e){
  Triangle left = e.left;
  Triangle right = e.right;
  if(right == null) return;
  
  for(int i=0; i<3; i++){
    if(right.edges[i].e.x == -e.e.x &&
      right.edges[i].e.y == -e.e.y){
      right.edges[i].right = left;
    }
  }
}

void findDT(){
  triangles.clear();
  triangles.add(pseudoTriangle);
  
  for(Vertex s : vertices){
    Triangle t = findIncludeTriangle(s);
    if(t == null)
      continue;
      
    makeThreeTriangle(s, t);
    while(!edgeStack.isEmpty()){ //<>//
      Edge e = edgeStack.pop();
      lawsonFlip(e);
    }
  }
}
