using UnityEngine;
using System.Collections;
 
public class ScrollingUVs : MonoBehaviour 
{
    public int materialIndex = 0;
    public Vector2 uvAnimationRate = new Vector2( 1.0f, 0.0f );
    public string textureName = "_MainTex";
    public bool isGlobal = false;

    Vector2 uvOffset = Vector2.zero;
 
    void LateUpdate() 
    {
        uvOffset += ( uvAnimationRate * Time.deltaTime );
        if( GetComponent<Renderer>().enabled )
        {
            if(!isGlobal){
            GetComponent<Renderer>().materials[ materialIndex ].SetTextureOffset( textureName, uvOffset );
            }
            else{
            GetComponent<Renderer>().sharedMaterials[ materialIndex ].SetTextureOffset( textureName, uvOffset );
            }
        }
    }
}