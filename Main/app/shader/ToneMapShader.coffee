module.exports = class ToneMapShader extends THREE.ShaderMaterial
  constructor: ()->
    super
    @vertexShader = """
    varying vec2 vUv;
    void main() {
      vUv = uv;
      gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
    }
    """
    @fragmentShader = """
    uniform sampler2D tInput;
    varying vec2 vUv;
    #{require("shader/HDRChunk")}
    vec3 pow(vec3 v, float e){
      return vec3(
        pow(v.x, e),
        pow(v.y, e),
        pow(v.z, e)
      );
    }
    void main() {
      vec3 color = fromHDR(texture2D(tInput, vUv).xyz);
      gl_FragColor = vec4(pow(color, 0.454545455), 1.0 );
    }
    """
      # float lum = dot(vec3(0.2126, 0.7152, 0.0722), color); // Wikipedia
      # gl_FragColor = vec4(pow(color/(0.5 + lum), 0.454545455), 1.0 );
    @uniforms = 
      tInput: 
        type: "t"
        value: null
      resolution:
        type: "v2"
        value: new THREE.Vector2()
      time:
        type: "f"
        value: 0
    @defaultAttributeValues = undefined
      #gl_FragColor = vec4( direction * 0.5 + 0.5, 1.0 );    }