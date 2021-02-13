using System.Collections;
using UnityEngine.InputSystem;
using UnityEngine;
using UnityEngine.InputSystem.Interactions;

// Using simple actions with callbacks.
public class PlayerControl : MonoBehaviour
{
    public float moveSpeed;
    public float jumpHeight;
    public float airMoveMult;
    public float groundCheckDist;
    public float rotateSpeed;
    public float smoothTurn;
    public GameObject projectile;
    public GameObject playerCamera;
    public Transform weaponOrigin;

    public InputAction moveAction;
    public InputAction lookAction;
    public InputAction fireAction;
    public InputAction jumpAction;
    [HideInInspector]
    public bool isGrounded = true;
    

    private Vector2 m_Rotation;
    private Vector2 c_Rotation;
    

    public void OnEnable()
    {
        moveAction.Enable();
        lookAction.Enable();
        fireAction.Enable();
        jumpAction.Enable();
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
        var look = lookAction.ReadValue<Vector2>();
        var move = moveAction.ReadValue<Vector2>();

        // Update orientation first, then move. Otherwise move orientation will lag
        // behind by one frame.
        Look(look);
        Move(move);
        Jump();

        if (fireAction.triggered)
        {
            Fire();
        }

    }


    float scaledMoveSpeed;
    private void Move(Vector2 direction)
    {
        //Make sure we're standing on something, otherwise limit the speed!
        if (Physics.Raycast(transform.position, Vector3.down, out hitInfo, groundCheckDist))
        {
            isGrounded = true;
        }
        else
        {
            isGrounded = false;
            transform.GetComponent<Rigidbody>().AddForce(Vector3.down, ForceMode.Acceleration);
        }
        if (!isGrounded)
        {
            scaledMoveSpeed = moveSpeed * Time.deltaTime * airMoveMult;
        }
        else
        {
            scaledMoveSpeed = moveSpeed * Time.deltaTime;
        }
        // For simplicity's sake, we just keep movement in a single plane here. Rotate
        // direction according to world Y rotation of player.
        //var move = Quaternion.Euler(0, transform.eulerAngles.y, 0) * new Vector3(direction.x, 0, direction.y);
        var move = new Vector3(direction.x, 0, direction.y);
        //Apply Move
        //transform.position += move * scaledMoveSpeed;
        transform.GetComponent<Rigidbody>().AddRelativeForce(move * scaledMoveSpeed, ForceMode.VelocityChange);
    }

    RaycastHit hitInfo;
    private void Jump()
    {
        if (jumpAction.triggered && isGrounded)
        {
            transform.GetComponent<Rigidbody>().AddForce(transform.up * jumpHeight, ForceMode.Impulse);
            isGrounded = false;
        }
    }

    public void OnGUI()
    {
        if (isGrounded)
            GUI.Label(new Rect(100, 100, 200, 100), "Grounded...");
        else
            GUI.Label(new Rect(100, 100, 200, 100), "Jump/Falling...");
    }

    private Vector3 SmoothLookBase;
    private Vector3 SmoothLookCam;

    private void Look(Vector2 rotate)
    {
        //if (rotate.sqrMagnitude < 0.01)
        //    return;
        var scaledRotateSpeed = rotateSpeed * Time.deltaTime;
        m_Rotation.y += rotate.x * scaledRotateSpeed;
        c_Rotation.x = Mathf.Clamp(c_Rotation.x - rotate.y * scaledRotateSpeed, -89, 89);
        SmoothLookBase = Vector3.Lerp(SmoothLookBase,m_Rotation, smoothTurn);
        SmoothLookCam = Vector3.Lerp(SmoothLookCam,c_Rotation, smoothTurn);
        //Apply Look
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
