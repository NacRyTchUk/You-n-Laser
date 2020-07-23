using UnityEngine;


public class PlayerAnimation : MonoBehaviour {
   
	private Animator _anim;
    private PlayerMove _pm;
    private static readonly int IsWalk = Animator.StringToHash("isWalk");
    private static readonly int IsOnGround = Animator.StringToHash("isOnGround");
    private static readonly int IsJump = Animator.StringToHash("isJump");
    private static readonly int IsRunning = Animator.StringToHash("isRunning");


    private void Start () {
		_anim = GetComponent<Animator>();
        _pm = GetComponent<PlayerMove>();

	}

    private void Update () {
		if ((Input.GetKey(KeyCode.LeftArrow) || Input.GetKey(KeyCode.RightArrow)) && !(Input.GetKey(KeyCode.LeftArrow) && Input.GetKey(KeyCode.RightArrow))) 
			_anim.SetBool(IsWalk,true);
        else 
            _anim.SetBool(IsWalk, false);

       
        if (_pm.isOnGround())
        {
            _anim.SetBool(IsOnGround, true);

            _anim.SetBool(IsJump, Input.GetKeyDown(KeyCode.Space));
        }
        else
            _anim.SetBool(IsOnGround, false);


        _anim.SetBool(IsRunning, _pm.vShift);


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
