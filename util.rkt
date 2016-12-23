#lang racket

[provide make-shader create-vertex-buffer VertexBuffer VertexBuffer-vertex-buffer VertexBuffer-vertex-count VertexBuffer-index-buffer VertexBuffer-vertex-array VertexBuffer-index-count VertexBuffer-draw-type]

[require racket/serialize racket/gui ffi/vector math/matrix opengl opengl/util finalizer "logger.rkt"]

[struct VertexBuffer (vertex-array index-buffer index-count vertex-buffer vertex-count draw-type) #:prefab]

[define (create-vertex-buffer vertices-original draw-type)
  [begin
    [trce "Creating new vertex buffer names"]
    [let ([v-array [glGenVertexArrays 1]]
          [vertices [map real->single-flonum [flatten vertices-original]]]
          [elem-per-vertex [length [car vertices-original]]])
      [trce "Binding buffer to the gl-context"]
      [glBindVertexArray [u32vector-ref v-array 0]]
      [trce "Generating the new buffer"]
      [let* ([vertex-buffers [glGenBuffers 1]]
             [index-buffers [glGenBuffers 1]]
             [vertex-buffer [u32vector-ref vertex-buffers 0]]
             [index-buffer [u32vector-ref index-buffers 0]]
             [size-of-single-flonum 4])
        [trce "Initializing buffer with points"
          `[vertex-count ,[length vertices]]
          `[length-divisible-by-elements? ,[= [modulo [length vertices] elem-per-vertex] 0]]
          `[points ,vertices]]
        [let ([vertex-buffer-f32 [list->f32vector vertices]])
          [let-values ([(type pointer) [gl-vector->type/cpointer vertex-buffer-f32]])
            [glBindBuffer GL_ARRAY_BUFFER vertex-buffer]
            [trce "Uploading data to buffer" `[id ,vertex-buffer]]
            [glBufferData GL_ARRAY_BUFFER [* size-of-single-flonum [length vertices]]
              pointer GL_STATIC_DRAW]
            [trce "Uploaded data"]
            [let ([index 0]
                  [size elem-per-vertex]
                  [type GL_FLOAT]
                  [normalized #f]
                  [stride 0]
                  [offset 0])
              [glEnableVertexAttribArray 0]
              [glVertexAttribPointer index size type normalized stride offset]
              [glBindBuffer GL_ELEMENT_ARRAY_BUFFER index-buffer]
              [let ([array-buffer-u32 [list->u32vector [stream->list [in-range [length vertices-original]]]]])
                [let-values ([(type pointer) [gl-vector->type/cpointer array-buffer-u32]])
                  [glBufferData GL_ELEMENT_ARRAY_BUFFER [* [length vertices-original] 4] pointer GL_STATIC_DRAW]]]
              [VertexBuffer [u32vector-ref v-array 0] index-buffer [length vertices-original] vertex-buffer [/ [length vertices] elem-per-vertex] draw-type]]]]]]]]

[define [make-shader file type]
  [define shader [glCreateShader type]]
  [define code [file->string file]]
  [glShaderSource shader 1 [vector code] [s32vector [string-length code]]]
  [glCompileShader shader]
  [define compile-status [glGetShaderiv shader GL_COMPILE_STATUS]]
  [define log-length [glGetShaderiv shader GL_INFO_LOG_LENGTH]]
  [trce `[Shader-compile-status-code ,compile-status]]
  [when [= compile-status 1]
    [dbug "Compiled shader OK"]]
  [when [> log-length 0]
    [define-values [count bytes] [glGetShaderInfoLog shader log-length]]
    [crit "Compiled shader ERR" `[message ,bytes]]]
  shader]

[struct point (x y) #:prefab]

[define (point- from to)
  [point [- [point-x to] [point-x from]]
         [- [point-y to] [point-y from]]]]

[define (fraction number)
  [- number [truncate number]]]

[define (trace-ray from-x from-y to-x to-y)
  [let* ([from-x [real->single-flonum from-x]]
         [from-y [real->single-flonum from-y]]
         [to-x [real->single-flonum to-x]]
         [to-y [real->single-flonum to-y]]
         [vx [- to-x from-x]]
         [vy [- to-y from-y]]
         [dx [sqrt [+ 1.0f0 [/ [* vy vy] vx vx]]]]
         [dy [sqrt [+ 1.0f0 [/ [* vx vx] vy vy]]]]
         [ix [floor from-x]]
         [iy [floor from-y]]
         [sx [if [< vx 0] -1 1]]
         [sy [if [< vy 0] -1 1]]
         [ex [* [if [< vx 0] [fraction from-x] [- 1 [fraction from-x]]] dx]]
         [ey [* [if [< vy 0] [fraction from-y] [- 1 [fraction from-y]]] dy]]
         [length [+ [abs [- [floor to-x] [floor from-x]]] [abs [- [floor to-y] [floor from-y]]]]])
    [let-values ([(points ex ey ix iy)
      [for/fold ([points [stream]]
                 [ex ex]
                 [ey ey]
                 [ix ix]
                 [iy iy])
                ([_ [range 0 length]])
        [let ([appendage [stream-append points [stream [point ix iy]]]])
          [if [< ex ey]
            [values appendage [+ ex dx] ey [+ ix sx] iy]
            [values appendage ex [+ ey dy] ix [+ iy sy]]]]]])
      [stream-append points [stream [point [floor to-x] [floor to-y]]]]]]]

[time [void [for/list ([i [trace-ray 0 30.5 0 0.7]]) i]]]
