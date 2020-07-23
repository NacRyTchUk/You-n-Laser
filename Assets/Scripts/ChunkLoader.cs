using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.IO;

public class ChunkLoader : MonoBehaviour {
    public GameObject parentsOfChunks;
    private readonly Chunk _curChunk = new Chunk();

    private void Start () {
        
        _curChunk.SetCoords(0,0);

        _curChunk.Load(parentsOfChunks);
       
	}
	
}
