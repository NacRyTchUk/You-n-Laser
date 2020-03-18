using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player_Move : MonoBehaviour
{
    public float hforce, vforce, hSpeed, vSpeed,hBoost,camSpeed;
   // public bool isOnGround;
    Rigidbody2D rb;
    public Camera Cam;
    public int minYValue;
    BoxCollider2D Cdrd;
    public bool isGrounded;
    public Transform SpawnPoint;
    [SerializeField]
    private LayerMask LayerSolidGroundMask;

    float smoothX, smoothY, smoothZ,smoothEndZ;
    void Start()
    {
        rb = transform.GetComponent<Rigidbody2D>();
        Cdrd = transform.GetComponent<BoxCollider2D>();
        smoothEndZ = Cam.transform.position.z;
    }


    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space) && isOnGround())
            rb.velocity = Vector2.up * vforce;
    }

    void FixedUpdate()
    {

        if (transform.position.y < minYValue) transform.position = new Vector3(SpawnPoint.transform.position.x,SpawnPoint.transform.position.y,transform.position.z);
        
        if (isOnGround()) isGrounded = true; else isGrounded = false;


        if (Input.GetKey(KeyCode.RightArrow))
        {
            if (!isWallAround(Vector2.right)) rb.velocity = new Vector2(hforce,rb.velocity.y);
        }
        else if (Input.GetKey(KeyCode.LeftArrow))
        {
            if (!isWallAround(Vector2.left))  rb.velocity = new Vector2(-hforce, rb.velocity.y);
        }
        else
        {
            rb.velocity = new Vector2(rb.velocity.x, rb.velocity.y);
        }


        int camStepZ = 5;
        if (Input.GetAxis("Mouse ScrollWheel") > 0) smoothEndZ = Cam.transform.position.z + camStepZ;
        if (Input.GetAxis("Mouse ScrollWheel") < 0) smoothEndZ = Cam.transform.position.z - camStepZ;
         

        smoothZ = Mathf.SmoothStep(Cam.transform.position.z, smoothEndZ, camSpeed);
        smoothX = Mathf.SmoothStep(Cam.transform.position.x, transform.position.x, camSpeed);
        smoothY = Mathf.SmoothStep(Cam.transform.position.y, transform.position.y, camSpeed);
        Cam.transform.position = new Vector3(smoothX, smoothY, smoothZ);
    
    }

    public bool isOnGround()
    {
        float rayMaxLenght = .05f;
        RaycastHit2D rchleft = Physics2D.Raycast(new Vector2(Cdrd.bounds.min.x, Cdrd.bounds.center.y), Vector2.down, Cdrd.bounds.extents.y + rayMaxLenght, LayerSolidGroundMask);
        RaycastHit2D rchright = Physics2D.Raycast(new Vector2(Cdrd.bounds.max.x, Cdrd.bounds.center.y), Vector2.down, Cdrd.bounds.extents.y + rayMaxLenght, LayerSolidGroundMask);
        
        if (rchleft.collider != null)
            Debug.DrawRay(new Vector3(Cdrd.bounds.min.x, Cdrd.bounds.center.y, transform.position.z), Vector2.down * (Cdrd.bounds.extents.y + rayMaxLenght), Color.green);
        else
            Debug.DrawRay(new Vector3(Cdrd.bounds.min.x, Cdrd.bounds.center.y, transform.position.z), Vector2.down * (Cdrd.bounds.extents.y + rayMaxLenght), Color.red);

        if (rchright.collider != null)
            Debug.DrawRay(new Vector3(Cdrd.bounds.max.x, Cdrd.bounds.center.y, transform.position.z), Vector2.down * (Cdrd.bounds.extents.y + rayMaxLenght), Color.green);
        else
            Debug.DrawRay(new Vector3(Cdrd.bounds.max.x, Cdrd.bounds.center.y, transform.position.z), Vector2.down * (Cdrd.bounds.extents.y + rayMaxLenght), Color.red);

        
        return ((rchleft.collider != null) || (rchright.collider != null));
    }

    public bool isWallAround(Vector2 vec2)
    {
        float rayMaxLenght = .05f;
        RaycastHit2D rchup = Physics2D.Raycast(new Vector2(Cdrd.bounds.center.x, Cdrd.bounds.max.y), vec2, Cdrd.bounds.extents.x + rayMaxLenght, LayerSolidGroundMask);
        RaycastHit2D rchdown = Physics2D.Raycast(new Vector2(Cdrd.bounds.center.x, Cdrd.bounds.min.y), vec2, Cdrd.bounds.extents.x + rayMaxLenght, LayerSolidGroundMask);

        if (rchup.collider != null)
            Debug.DrawRay(new Vector3(Cdrd.bounds.center.x, Cdrd.bounds.max.y, transform.position.z), vec2 * (Cdrd.bounds.extents.x + rayMaxLenght), Color.green);
        else
            Debug.DrawRay(new Vector3(Cdrd.bounds.center.x, Cdrd.bounds.max.y, transform.position.z), vec2 * (Cdrd.bounds.extents.x + rayMaxLenght), Color.red);
        
        if (rchup.collider != null)
            Debug.DrawRay(new Vector3(Cdrd.bounds.center.x, Cdrd.bounds.min.y, transform.position.z), vec2 * (Cdrd.bounds.extents.x + rayMaxLenght), Color.green);
        else
            Debug.DrawRay(new Vector3(Cdrd.bounds.center.x, Cdrd.bounds.min.y, transform.position.z), vec2 * (Cdrd.bounds.extents.x + rayMaxLenght), Color.red);



        return ((rchup.collider != null) || (rchdown.collider != null));
    }
 
}