using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class Player_Animation : MonoBehaviour {
   
	private Animator anim;
    Player_Move pm;

    
	void Start () {
		anim = GetComponent<Animator>();
        pm = GetComponent<Player_Move>();

	}
	
	void Update () {
		if ((Input.GetKey(KeyCode.LeftArrow) || Input.GetKey(KeyCode.RightArrow)) && !(Input.GetKey(KeyCode.LeftArrow) && Input.GetKey(KeyCode.RightArrow))) 
			anim.SetBool("isWalk",true);
		 else 
            anim.SetBool("isWalk", false);

       
        if (pm.isOnGround())
        {
            anim.SetBool("isOnGround", true);

            if (Input.GetKeyDown(KeyCode.Space))

                anim.SetBool("isJump", true);
            else
                anim.SetBool("isJump", false);
        }
        else
            anim.SetBool("isOnGround", false);



        if (pm.vShift) anim.SetBool("isRunning", true);
        else anim.SetBool("isRunning", false); 

       
        
            

        if ((Input.GetKey(KeyCode.LeftArrow)) && (!Input.GetKey(KeyCode.RightArrow)))
        {
            transform.localScale = new Vector2(-1.0f, 1.0f);
        }

        if ((Input.GetKey(KeyCode.RightArrow)) && (!Input.GetKey(KeyCode.LeftArrow)))
        {
            transform.localScale = new Vector2(1.0f, 1.0f);
        }
	}
}
