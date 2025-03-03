# Hello, and welcome to the Documentation of the CLVM [Custom Lua Virtual Machine], Let's get started.

[[
  # REQURIEMENTS TO USE THE CLVM
  
 - Exploit Function Requirements: loadstring, cloneref, writefile
 - Exploit Level Requirements: Plugin, RobloxPlace, LocalUser [1], [2], [3]
]]

- To create a new CLVM, you can do this by using `CLVM.new()`. Here's an example:

  ```lua
  -- First off, the CLVM must be loaded with it's additional table and other functions.
  
   local Virtual_Machine = CLVM.new() -- This will start a new Virtual Machine for you to experiment in and use it's functions, Let's dive into those!
  ```

  After creating the CLVM by using `CLVM.new()`, you can use the custom functions of CLVM, Here are some of them:

  `CLVM.GetScriptSource<S>(script: LocalScript | ModuleScript): S - Gets the Source of a Lua Source Container [LocalScripts, ModuleScripts, LuaSourceContainers], Example: `
  
   ```lua
    local LocalScript = Instance.new("LocalScript");
    LocalScript.Name = "LocalScript"
    LocalScript.Parent = game.Players.LocalPlayer.PlayerGui -- Choose any path inside of game.
    LocalScript.Source = [[ print("Hello, World") ]]
     print(CLVM.GetScriptSource(LocalScript) --> print("Hello, World")
   ```
   
  `CLVM:execute<C>(code: string): C - Executes code inside of the string, For example: `
   ```lua
    CLVM:execute([[
        print("Hello, World!")
   ]])
   -- Console Output --> Hello, World!
   -- Another function for CLVM:execute(): CLVM:RunOnThread

   -- This runs your code on a seperate thread which uses task.spawn, To use it you just do

    CLVM:RunOnThread([[
       print("This is ran on task.spawn, making your code more efficient.");
       -- Console Output --> This is ran on task.spawn, making your code more efficient.
   ]])
   
   ```

   `CLVM:GetOutput() - Returns a concatted table of CLVM.output`
   `CLVM:EmptyCharacter() - This is used for hiding Script names or just strings, it returns \0, which is a C parameter for empty strings. it is also used for empty bytecode strings. Usage:`
  
    ```lua
     local Name: string = CLVM:EmptyCharacter()
     print(Name == "") --> true
    ```
    `CLVM:GetError() - Used to get errors inside of the CLVM, This is mostly the cause of why everything is sandboxed.`
    `CLVM:AddFunction() - This adds a function to the Environment of the CLVM, for example: `
     ```lua
      local Virtual_Machine = CLVM:new()
     Virtual_Machine:AddFunction("getscriptname" function(scr: Instance)
          print(scr.Name) -- This adds `getscriptname` to the CLVM's environment, to access the function, you can do
         -- Virtual_Machine["getscriptname"](LocalScript) or CLVM["getscriptname"](LocalScript) --> LocalScript
         -- Always remember, when using CLVM.new(), you are simply cloning the CLVM as used previously. This is why the term `sandboxed` is mentioned 2 times here. [3]
     end)
     ```
     `CLVM:RemoveFromEnvironment() - Removes a function from the CLVM environment. Example: `
     ```lua
       local Virtual_Machine = CLVM.new()
        Virtual_Machine:RemoveFromEnvironment(getscriptname)
        print(Virtual_Machine["getscriptname"]) --> nil
     ```
     `CLVM:IsInEnvironment() - Checks if a function is inside the CLVM's env, example: `
     ```lua
      local Virtual_Machine = CLVM.new()
       Virtual_Machine:IsInEnvironment("getscriptname")
       -- The way this works is it checks if the function exists before going on to execute it, so if the function exists, it will return
       -- true, if not, return false. so you mostly need to print the result:
       print(Virtual_Machine:IsInEnvironment("getscriptname")) --> true if the function exists.
     ```
     `CLVM:CreateBuffer() - This revamps the old Lua Buffer Library from the LuaRocks original package, as Roblox has it installed automatically, Here's how to use it: `
     ```lua
       local Virtual_Machine = CLVM.new()
       local VM_Buffer = Virtual_Machine:CreateBuffer()

       local a = VM_Buffer:write(1, "Hello")
      print(a:read(1)) --> Hello
      print(a:read(2)) --> nil, This happens because it checks if the buffer location exists, for example:
      -- VM_Buffer:write(1 -- This is the path of where you'll be storing that written string, "Hello" -- The written string that you want to write.)

     ```
    `CLVM:SaveInstances -- Saves all instances inside of the game, This is shit due to it just saving its-self to a .TXT file, as it saves the Parent and Name of the instances. Example:`
    `This doesn't actually need an example, but here are some methods to use in this function: CLVM:SaveInstances(ModuleScripts) - Saves all ModuleScripts into 1 TXT file inside of your exploit's workspace folder. Requires writefile`
    `CLVM:SaveInstances(LocalScripts) --> Saves all LocalScripts into 1 TXT file inside of your exploit's workspace folder.`
     
