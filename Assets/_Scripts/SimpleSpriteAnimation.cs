using UnityEngine;

[RequireComponent(typeof(SpriteRenderer))]
public class SimpleSpriteAnimation : MonoBehaviour
{
	[HideInInspector]
	public bool isDone;

	[SerializeField]
	bool loop;

	[SerializeField]
	Sprite[] frames = null;
	 
	[SerializeField]
	float animationSpeed = 1f;

	SpriteRenderer spriteRenderer;
	int currentFrameIndex = 0;
	float animationTimer = 0f;

	void Start()
	{
		spriteRenderer = GetComponent<SpriteRenderer>();
		isDone = false;
	}

	void Update()
	{
		if (isDone)
		{
			return;
		}

		animationTimer += Time.deltaTime;

		if (animationTimer > animationSpeed)
		{
			currentFrameIndex++;

			if (currentFrameIndex >= frames.Length)
			{
				if (loop)
				{
					currentFrameIndex = 0;
				}
			}
			else if (currentFrameIndex >= frames.Length - 1 && !loop)
			{
				isDone = true;
			}

			spriteRenderer.sprite = frames[currentFrameIndex];

			animationTimer = 0f;
		}
	}
}
