class Vertex{
  PVector position, velocity;
  Vertex(float x, float y){
    position = new PVector(x, y);
  }
}

class Edge{
  // vertices[0] : from
  // vertices[1] : to
  Vertex vertices[] = new Vertex[2];
  PVector e;
  Triangle left, right;
  
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
    }
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
