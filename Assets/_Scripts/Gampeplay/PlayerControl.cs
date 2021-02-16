using System.Collections;
using UnityEngine.InputSystem;
using UnityEngine;
using UnityEngine.InputSystem.Interactions;
//using System;

// Using simple actions with callbacks.
public class PlayerControl : MonoBehaviour
{
    [Header("Movement Settings")]
    public float moveSpeed;
    
    [Header("Aiming Settings")]
    public float rotateSpeed;
    public bool smoothAim; 
    public float smoothTurn;
    public bool smoothRecenter;
    public int recenteringDetectAngleMin;
    public float recenteringSmoothness;
    public float recenteringDelay;
    public Vector2 verticalLimit;


    [Header("Jumping Settings")]
    public float jumpHeight;
    public float airMoveMult;
    public float groundCheckDist;
    public float enhancedGravity;
    public PhysicMaterial inAirPhysMat;
    public PhysicMaterial groundedPhysMat;

    [Header("Testing")]
    public GameObject projectile;
    public Transform weaponOrigin;
    
    [Header("Setup")]
    public GameObject playerCamera;
    public InputAction moveAction;
    public InputAction lookAction;
    public InputAction fireAction;
    public InputAction jumpAction;
    [HideInInspector]
    public bool isGrounded = true;
    

    private Vector2 m_Rotation;
    private Vector2 c_Rotation;
    private Rigidbody playerPhys;
    private CapsuleCollider playerCollision;

    GUIStyle activeStyle;
    GUIStyle disableStyle;

    //Init controls and important things! 
    public void OnEnable()
    {
        moveAction.Enable();
        lookAction.Enable();
        fireAction.Enable();
        jumpAction.Enable();
        playerPhys = transform.GetComponent<Rigidbody>();
        playerCollision = transform.GetComponent<CapsuleCollider>();
        //Debug text color settings
        activeStyle = new GUIStyle();
        activeStyle.normal.textColor = new Color(1f,.5f,0);
        disableStyle = new GUIStyle();
        disableStyle.normal.textColor = Color.red;
    }

    public void OnDisable()
    {
        moveAction.Disable();
        lookAction.Disable();
        fireAction.Disable();
        jumpAction.Disable();
    }

    public void Update()
    {
        //Get the inputs from the controllers 
        var look = lookAction.ReadValue<Vector2>();
        var move = moveAction.ReadValue<Vector2>();

        // Update orientation first, then move. Otherwise move orientation will lag
        // behind by one frame.
        Look(look);
        Move(move);
        Jump();
        //Check for test actions! 
        if (fireAction.triggered)
        {
            Fire();
        }

    }

    float scaledMoveSpeed;
    private void Move(Vector2 direction)
    {
        //Make sure we're standing on something, otherwise apply extra gravity to offset player movement drag! 
        if (Physics.Raycast(transform.position, Vector3.down, out hitInfo, groundCheckDist))
        {
            isGrounded = true;
        }
        else
        {
            isGrounded = false;
            playerPhys.AddForce(Vector3.down*enhancedGravity, ForceMode.Acceleration);
        }
        //If the player is grounded limit the speed that they can move!
        if (isGrounded)
        {
            scaledMoveSpeed = moveSpeed * Time.deltaTime;
        }
        else 
        {
            scaledMoveSpeed = moveSpeed * Time.deltaTime * airMoveMult;
        }
        // For simplicity's sake, we just keep movement in a single plane here. Rotate
        // direction according to world Y rotation of the player's base object.
        var move = new Vector3(direction.x, 0, direction.y);
        //Apply Move via physics!
        playerPhys.AddRelativeForce(move * scaledMoveSpeed, ForceMode.VelocityChange);
    }




    RaycastHit hitInfo;

    private void Jump()
    {        
        //Before we jump, check to make sure the player wants to, and is currently on the ground. 
        if (jumpAction.triggered && isGrounded)
        {
            //Do a Jump! 
            playerPhys.AddForce(transform.up * jumpHeight, ForceMode.Impulse);
            isGrounded = false;
        }
        if (isGrounded) {
            //Make sure the player is behaving like a typical physics object while grounded
            playerCollision.material = groundedPhysMat;
        }
        else {
            //make sure the player is super slippery when in the air to keep from getting stuck on walls and steps. 
            playerCollision.material = inAirPhysMat;
        }
    }





    //Debug information - helps me track the player's state. 
    public void OnGUI()
    {
        if (isGrounded)
            GUI.Label(new Rect(100, 100, 200, 100), "Grounded...", activeStyle);
        else
            GUI.Label(new Rect(100, 100, 200, 100), "Jump/Falling...",disableStyle);
    }




    private Vector3 SmoothLookBase;
    private Vector3 SmoothLookCam;
    private float recenterTimer;
    private bool minAngleDetected;

    private void Look(Vector2 rotate)
    {
        //First we set up the basic input from the player controls, and map them to the main player controller and camera separately - The controller spins around,
        //and the camera aims up or down
        var scaledRotateSpeed = rotateSpeed * Time.deltaTime;
        m_Rotation.y += rotate.x * scaledRotateSpeed;
        c_Rotation.x = Mathf.Clamp(c_Rotation.x - rotate.y * scaledRotateSpeed, verticalLimit.y, verticalLimit.x);
        //Support for the re-centering smooth blend
        if (smoothRecenter)
        {
            //Is the player actively trying to control the camera? If not, countdown to re-center the camera.
            if (Mathf.Abs(rotate.y) < 0.02)
            {
                if (recenterTimer > 0)
                    recenterTimer -= Time.deltaTime;
            }
            //Or do nothing, and let the player do whatever
            else
            {
                recenterTimer = recenteringDelay;
                minAngleDetected = false;
            }
            //Okay, timers run out - lets smoothly recenter. Only do this if the deviation from horizontal is more than recenteringDetectAngleMin, 
            //otherwise just ignore it.
            if (recenterTimer <= 0 && Mathf.Abs(c_Rotation.x) > recenteringDetectAngleMin)
            {
                minAngleDetected = true;
            }
            if (recenterTimer <= 0 && minAngleDetected)
            {
                c_Rotation.x = Mathf.Lerp(c_Rotation.x, 0, recenteringSmoothness);
                if (Mathf.Abs(c_Rotation.x) <= 0.0005)
                {
                    minAngleDetected = false;
                }
            }
        }
        //This is an additional layer of smoothing added in to just make it a *little* nicer on gamepads and twitchy mice. :D Totally optional.
        if (smoothAim)
        {
            SmoothLookBase = Vector3.Lerp(SmoothLookBase, m_Rotation, smoothTurn);
            SmoothLookCam = Vector3.Lerp(SmoothLookCam, c_Rotation, smoothTurn);
        }
        else {
            SmoothLookBase = m_Rotation;
            SmoothLookCam = c_Rotation;
        }
        //Apply Look to the respective transforms.
        transform.localEulerAngles = SmoothLookBase;
        playerCamera.transform.localEulerAngles = SmoothLookCam;
    }

    private void Fire()
    {
        var transform = this.transform;
        var newProjectile = Instantiate(projectile);
        newProjectile.transform.position = weaponOrigin.position;// transform.position + playerCamera.transform.forward * 0.6f;
        newProjectile.transform.rotation = transform.rotation;
        var size = 1;
        newProjectile.transform.localScale *= size;
        newProjectile.GetComponent<Rigidbody>().mass = Mathf.Pow(size, 3);
        newProjectile.GetComponent<Rigidbody>().AddForce(playerCamera.transform.forward * 60f, ForceMode.Impulse);
        newProjectile.GetComponent<MeshRenderer>().material.color =
            new Color(Random.value, Random.value, Random.value, 1.0f);
    }


}
