class Vertex{
  PVector position, velocity;
  boolean isPseudo = false;
  Vertex(float x, float y){
    position = new PVector(x, y);
  }
  Vertex(PVector p){
    position = p.copy();
  }
  void update(){
    position.add(velocity);
    
    if(position.x > width || position.x < 0) velocity.x *= -1;
    if(position.y > height || position.y < 0) velocity.y *= -1;
  }
}

class Edge{
  // vertices[0] : from
  // vertices[1] : to
  Vertex vertices[] = new Vertex[2];
  PVector e;
  Triangle left, right;
  boolean isDeleted = false;
  boolean isPseudo = false;
}

class Triangle{
  Vertex vertices[] = new Vertex[3];
  Edge edges[] = new Edge[3];
  
  void createEdges(){
    for(int i=0; i<3; i++){
      Vertex v1 = vertices[i];
      Vertex v2 = vertices[(i+1)%3];
      edges[i] = new Edge();
      edges[i].vertices[0] = v1;
      edges[i].vertices[1] = v2;
      edges[i].left = this;
      edges[i].e = PVector.sub(v2.position, v1.position);
      
      if(v1.isPseudo || v2.isPseudo)
        edges[i].isPseudo = true;
    }
  }
  
  void setPseudo(){
    for(int i=0; i<3; i++){
      vertices[i].isPseudo = true;
    }
  }
  
  void removeEdges(){
    edges[0].isDeleted = edges[1].isDeleted = edges[2].isDeleted = true; 
  }
}

class Pair{
  Edge e;
  Triangle t;
  Pair(Edge e, Triangle t){
    this.e = e;
    this.t = t;
  }
}
