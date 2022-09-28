// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract TodoList {
    struct Todo {
        string text;
        bool completed;
    }

    Todo[] public todos;

    function create(string calldata _text) external {
        todos.push(
            Todo({
                text: _text,
                completed: false
            })
        );
    }

    function updateText(uint _index, string calldata _text) external {
        todos[_index].text = _text;
    }

    function get(uint _index) external view returns(string memory, bool) {
        Todo memory chosenTodo = todos[_index];
        return (chosenTodo.text, chosenTodo.completed);
    }

    function toggleCompleted(uint _index) external {
        todos[_index].completed = !todos[_index].completed;
    }
}