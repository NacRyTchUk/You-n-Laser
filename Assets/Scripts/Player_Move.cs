using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Player_Move : MonoBehaviour
{
    public float hforce, vforce, camSpeed, shiftBoost, vBoost;
    public int minYValue;
    public bool isGrounded, vShift;
    
    [SerializeField]
    Camera Cam;
    [SerializeField]
    Transform SpawnPoint;
    [SerializeField]
    LayerMask LayerSolidGroundMask;

    float smoothX, smoothY, smoothZ,smoothEndZ;
    Rigidbody2D rb;
    BoxCollider2D Cdrd;



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
        if (Input.GetKey(KeyCode.LeftShift)) vShift = true;
        else vShift = false;

        if (transform.position.y < minYValue) transform.position = new Vector3(SpawnPoint.transform.position.x, SpawnPoint.transform.position.y, transform.position.z);
        
        if (isOnGround()) isGrounded = true; else isGrounded = false;

        

        if (Input.GetKey(KeyCode.RightArrow))
        {
            rb.transform.position = new Vector3(transform.position.x, transform.position.y + vBoost, transform.position.z);
            if ((!isWallAround(Vector2.right) || isOnGround()) && !Input.GetKey(KeyCode.LeftArrow))
                rb.velocity = new Vector2(hforce + shiftBoost * Convert.ToInt32(vShift), rb.velocity.y);
        }
        else if (Input.GetKey(KeyCode.LeftArrow))
        {
            rb.transform.position = new Vector3(transform.position.x, transform.position.y + vBoost, transform.position.z);
            if ((!isWallAround(Vector2.left) || isOnGround()) && !Input.GetKey(KeyCode.RightArrow))
                rb.velocity = new Vector2(-(hforce + shiftBoost * Convert.ToInt32(vShift)), rb.velocity.y);
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
        RaycastHit2D rchmiddle = Physics2D.Raycast(new Vector2(Cdrd.bounds.center.x, Cdrd.bounds.center.y), Vector2.down, Cdrd.bounds.extents.y + rayMaxLenght, LayerSolidGroundMask);

        return ((rchleft.collider != null) || (rchright.collider != null) || (rchmiddle.collider != null));
    }

    public bool isWallAround(Vector2 vec2)
    {
        float rayMaxLenght = .02f;
        RaycastHit2D rchup = Physics2D.Raycast(new Vector2(Cdrd.bounds.center.x, Cdrd.bounds.max.y + rayMaxLenght), vec2, Cdrd.bounds.extents.x + rayMaxLenght, LayerSolidGroundMask);
        RaycastHit2D rchdown = Physics2D.Raycast(new Vector2(Cdrd.bounds.center.x, Cdrd.bounds.min.y - rayMaxLenght), vec2, Cdrd.bounds.extents.x + rayMaxLenght, LayerSolidGroundMask);
        RaycastHit2D rchmiddle = Physics2D.Raycast(new Vector2(Cdrd.bounds.center.x, Cdrd.bounds.center.y), vec2, Cdrd.bounds.extents.x + rayMaxLenght, LayerSolidGroundMask);

        return ((rchup.collider != null) || (rchdown.collider != null) || (rchmiddle.collider != null));
    }
 
}