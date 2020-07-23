using System;
using UnityEngine;


// [RequireComponent(typeof(Camera))]
// [RequireComponent(typeof(Transform))]
// [RequireComponent(typeof(BoxCollider2D))]
// [RequireComponent(typeof(Rigidbody2D))]
public class PlayerMove : MonoBehaviour
{
    public float hForce, vForce, camSpeed, shiftBoost, vBoost;
    public int minYValue;
    public bool isGrounded, vShift;
    
    [SerializeField] private Camera cam;
    [SerializeField] private Transform spawnPoint;
    [SerializeField] private LayerMask layerSolidGroundMask;

    private float _smoothX, _smoothY, _smoothZ, _smoothEndZ;
    private Rigidbody2D _rb;
    private BoxCollider2D _collider;


    private void Start()
    {
        _rb = transform.GetComponent<Rigidbody2D>();
        _collider = transform.GetComponent<BoxCollider2D>();
        _smoothEndZ = cam.transform.position.z;
    }


    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space) && isOnGround())
            _rb.velocity = Vector2.up * vForce;
    }

    private void FixedUpdate()
    {
        vShift = Input.GetKey(KeyCode.LeftShift);

        var transformPosition = transform.position;
        
        if (transform.position.y < minYValue)
        {
            var spawnPointTranPos = spawnPoint.transform.position;
            transformPosition = new Vector3(spawnPointTranPos.x, spawnPointTranPos.y, transform.position.z);
        }

        isGrounded = isOnGround();

        

        if (Input.GetKey(KeyCode.RightArrow))
        {
            _rb.transform.position = new Vector3(transformPosition.x, transformPosition.y + vBoost, transformPosition.z);
            if ((!IsWallAround(Vector2.right) || isOnGround()) && !Input.GetKey(KeyCode.LeftArrow))
                _rb.velocity = new Vector2(hForce + shiftBoost * Convert.ToInt32(vShift), _rb.velocity.y);
        }
        else if (Input.GetKey(KeyCode.LeftArrow))
        {
            _rb.transform.position = new Vector3(transformPosition.x, transformPosition.y + vBoost, transformPosition.z);
            if ((!IsWallAround(Vector2.left) || isOnGround()) && !Input.GetKey(KeyCode.RightArrow))
                _rb.velocity = new Vector2(-(hForce + shiftBoost * Convert.ToInt32(vShift)), _rb.velocity.y);
        }
        else
        {
            var velocity = _rb.velocity;
            velocity = new Vector2(velocity.x, velocity.y);
            _rb.velocity = velocity;
        }

        var camTransformPosition = cam.transform.position;

        const int camStepZ = 5;
        if (Input.GetAxis("Mouse ScrollWheel") > 0) _smoothEndZ = camTransformPosition.z + camStepZ;
        if (Input.GetAxis("Mouse ScrollWheel") < 0) _smoothEndZ = camTransformPosition.z - camStepZ;


        _smoothZ = Mathf.SmoothStep(camTransformPosition.z, _smoothEndZ, camSpeed);
        
        _smoothX = Mathf.SmoothStep(camTransformPosition.x, transformPosition.x, camSpeed);
        _smoothY = Mathf.SmoothStep(camTransformPosition.y, transformPosition.y, camSpeed);

        cam.transform.position = new Vector3(_smoothX, _smoothY, _smoothZ);
    }

    public bool isOnGround()
    {
        const float rayMaxLength = .05f;
        var bounds = _collider.bounds;
        RaycastHit2D rCastHitLeft = Physics2D.Raycast(new Vector2(bounds.min.x, bounds.center.y), Vector2.down, bounds.extents.y + rayMaxLength, layerSolidGroundMask);
        RaycastHit2D rCastHitRight = Physics2D.Raycast(new Vector2(bounds.max.x, bounds.center.y), Vector2.down, bounds.extents.y + rayMaxLength, layerSolidGroundMask);
        RaycastHit2D rCastHitMiddle = Physics2D.Raycast(new Vector2(bounds.center.x, bounds.center.y), Vector2.down, bounds.extents.y + rayMaxLength, layerSolidGroundMask);

        return ((rCastHitLeft.collider != null) || (rCastHitRight.collider != null) || (rCastHitMiddle.collider != null));
    }

    private bool IsWallAround(Vector2 vec2)
    {
        const float rayMaxLength = .02f;
        var bounds = _collider.bounds;
        RaycastHit2D rCastHitUp = Physics2D.Raycast(new Vector2(bounds.center.x, bounds.max.y + rayMaxLength), vec2, bounds.extents.x + rayMaxLength, layerSolidGroundMask);
        RaycastHit2D rCastHitDown = Physics2D.Raycast(new Vector2(bounds.center.x, bounds.min.y - rayMaxLength), vec2, bounds.extents.x + rayMaxLength, layerSolidGroundMask);
        RaycastHit2D rCastHitMiddle = Physics2D.Raycast(new Vector2(bounds.center.x, bounds.center.y), vec2, bounds.extents.x + rayMaxLength, layerSolidGroundMask);

        return ((rCastHitUp.collider != null) || (rCastHitDown.collider != null) || (rCastHitMiddle.collider != null));
    }
 
}