using System.Collections;
using System.Collections.Generic;
using System.IO;
using System;
using UnityEngine;
using UnityEngine.UI;
using Object = UnityEngine.Object;


internal struct Block
{
    public float x;
    public float y;
    public int mainLayer;
    public int blockIndex;
}

public class Chunk
{
    private Vector2 _coordsOfTheChunk;

    private readonly List<Block> _listOfBlocks = new List<Block>();

    private GameObject _parentOfChunk, _chunkObject;

    public void SetCoords(int x, int y)
    {
        _coordsOfTheChunk.x = x;
        _coordsOfTheChunk.y = y;
    }

    public void SetCoords(Vector2 coords)
    {
        _coordsOfTheChunk = coords;
    }


    public void DisplayInfo()
    {
        Debug.Log("Chunk x: " + _coordsOfTheChunk.x + ", y: " + _coordsOfTheChunk.y);
    }


    private void LoadInMemory()
    {
        TextAsset txtAsset = (TextAsset)Resources.Load("Map\\" + _coordsOfTheChunk.x + "," + _coordsOfTheChunk.y, typeof(TextAsset));
        var pageOfFile = txtAsset.text.Split('$');

        var bricksInFile = pageOfFile[0].Split(':');

        for (int i = 0; i < bricksInFile.Length; i++)
        {
            bricksInFile[i] = bricksInFile[i].Trim('[');
            bricksInFile[i] = bricksInFile[i].Trim(']');
            var elementsInBrick = bricksInFile[i].Split(';');
            Block newBlock;
            newBlock.blockIndex = Convert.ToInt32(elementsInBrick[0]);
            newBlock.x = Convert.ToSingle(elementsInBrick[1]);
            newBlock.y = Convert.ToSingle(elementsInBrick[2]);
            newBlock.mainLayer = Convert.ToInt32(elementsInBrick[3]);
            _listOfBlocks.Add(newBlock);
        }

    }

    private void LoadOnScreen()
    {

        _chunkObject = Object.Instantiate((GameObject)Resources.Load("Empty"), _parentOfChunk.transform);
        _chunkObject.name = _coordsOfTheChunk.x + "," + _coordsOfTheChunk.y;

        for (int i = 0; i < _listOfBlocks.Count; i++)
        {
            var newGameObject = Object.Instantiate((GameObject)Resources.Load("BlocksPrefabs/" + Convert.ToString(_listOfBlocks[i].blockIndex)), _chunkObject.transform);
            newGameObject.name = "[" + _listOfBlocks[i].blockIndex + ";" + _listOfBlocks[i].x + ";" + _listOfBlocks[i].y + ";" + _listOfBlocks[i].mainLayer + "]";
            newGameObject.transform.position = new Vector3(_listOfBlocks[i].x * 0.5f, _listOfBlocks[i].y * 0.5f, _listOfBlocks[i].mainLayer * 0.5f);
            if (_listOfBlocks[i].mainLayer == 0)
                newGameObject.AddComponent<BoxCollider2D>();
        }
    }

    public void Load(GameObject pom)
    {
        _parentOfChunk = pom;
        LoadInMemory();
        LoadOnScreen();
    }
}
