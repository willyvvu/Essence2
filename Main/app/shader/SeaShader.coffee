APhysicalShader = require("shader/APhysicalShader")
module.exports = class SeaShader extends THREE.ShaderMaterial
  constructor: (options)->
    super
    @vertexShader = """
    varying vec2 vUv;
    varying vec3 vWorldPosition;
    void main() {
      vUv = uv;
      vWorldPosition = position;
      gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
    }
    """
    # threejs.org/examples/webgl_shaders_ocean.html
    @fragmentShader = """
    uniform sampler2D tReflect;
    uniform sampler2D tNormal;
    uniform vec2 resolution;
    uniform float time;
    varying vec2 vUv;
    varying vec3 vWorldPosition;
    float mdot(vec3 a, vec3 b){
      return max(0.0, dot(a, b));
    }
    vec3 colorToVector(vec4 normalColor){
      return normalColor.xzy * 2.0 - 1.0;
    }
    void main() {
      vec3 lightPosition = #{APhysicalShader.LIGHT_POSITION};
      vec3 lightColor = #{APhysicalShader.LIGHT_COLOR};

      vec3 normalColor =
        colorToVector(texture2D(tNormal, vWorldPosition.xz * 0.005 + vec2(time * 0.0321, 0.0)))
        + colorToVector(texture2D(tNormal, vWorldPosition.xz * 0.0131 + vec2(time * 0.0213, 0.879)))
        + colorToVector(texture2D(tNormal, vWorldPosition.xz * 0.00454 + vec2(time * 0.0123, 0.423)));

      vec3 normal = normalize(vec3(1.0, 0.4, 1.0) * normalColor);

      vec3 cameraToWorld = vWorldPosition - cameraPosition;
      vec3 cameraView = normalize(cameraToWorld);
      
      float groundFresnel = pow(1.0 - mdot(vec3(0.0, 1.0, 0.0), -cameraView), 20.0);
      vec3 specular = lightColor * pow(mdot(reflect(lightPosition, vec3(0.0, 1.0, 0.0)), cameraView), 50.0);
      float reflectance = pow(1.0 - mdot(normal, -cameraView), 2.0);

      vec2 coord = gl_FragCoord.xy / resolution;
      coord.y = 1.0 - coord.y;
      vec3 reflectedColor = texture2D(tReflect, coord + normal.xz * (0.001 + 1.0 / length(cameraToWorld))).xyz;

      gl_FragColor = vec4(
        mix(reflectedColor * (0.2 + 0.1 * mdot(lightPosition, normal)), reflectedColor + specular, min(1.0, reflectance + groundFresnel))
        , 1.0
      );
    }
    """
    @uniforms = 
      tReflect: 
        type: "t"
        value: options.reflectionTexture
      tNormal: 
        type: "t"
        value: THREE.ImageUtils.loadTexture("images/Sea.png")
      resolution:
        type: "v2"
        value: new THREE.Vector2(0, 0)
      time:
        type: "f"
        value: 0
    @uniforms.tNormal.value.wrapT = THREE.RepeatWrapping
    @uniforms.tNormal.value.wrapS = THREE.RepeatWrapping
    @defaultAttributeValues = undefined

