using System;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class SceneBuffer : MonoBehaviour
{
	public static Camera sceneCamera;

	Camera playerCamera;
	Transform bufferPlane;

	[SerializeField]
	Vector2 targetResolution;

	void Start()
	{
		//Find Important objects
		sceneCamera = GetComponent<Camera>();
		playerCamera = GameObject.FindGameObjectWithTag("Player").GetComponentInChildren<Camera>();
		bufferPlane = transform.Find("BufferPlane").transform;
		//Set resolution on start
		playerCamera.activeTexture.height = Mathf.RoundToInt(targetResolution.y);
		playerCamera.activeTexture.width = Mathf.RoundToInt(targetResolution.x);
		bufferPlane.localScale = new Vector3(targetResolution.x, targetResolution.y, 1);
		//If there's any difference from the target resolution and the desired resolution's aspect ratios, add black bars:
		if (!sceneCamera)
		{
			sceneCamera = GetComponent<Camera>();
		}

		float variance = (targetResolution.x / targetResolution.y) / sceneCamera.aspect;

		if (variance > 1f)
		// if we would need black bars at the top and bottom (letterboxing)
		{
			sceneCamera.orthographicSize = variance * targetResolution.y * 0.5f;
		}
		else
		// if we would need black bars left and right (pillarboxing)
		{
			sceneCamera.orthographicSize = targetResolution.y * 0.5f;
		}
	}
}
