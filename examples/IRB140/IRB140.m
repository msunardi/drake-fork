classdef IRB140 < TimeSteppingRigidBodyManipulator
  methods
    
    function obj=IRB140(urdf,options)
      typecheck(urdf,'char');
      
      if nargin < 2
        options = struct();
      end
      if ~isfield(options,'dt')
        options.dt = 0.001;
      end
      if ~isfield(options,'floating')
        options.floating = true;
      end
      if ~isfield(options,'terrain')
        options.terrain = RigidBodyFlatTerrain;
      end
      if ~isfield(options,'hands')
        options.hands = 'none';
      end
      
      obj = obj@TimeSteppingRigidBodyManipulator('',options.dt,options);
      obj.initialized = 1;
      obj = obj.addRobotFromURDF(urdf,[0,0,0]',[-pi/2, 0, 0]',options);
      
      if (~strcmp(options.hands, 'none'))
        if (strcmp(options.hands, 'robotiq'))
          options_hand.weld_to_link = 7;
          obj.hands = 1;
          obj = obj.addRobotFromURDF(getFullPathFromRelativePath('../Atlas/urdf/robotiq.urdf'), [0.1; 0.0; 0.0], [pi; 0; pi/2], options_hand);
        elseif (strcmp(options.hands, 'robotiq_weight_only'))
          % Adds a box with weight roughly approximating the hands, so that
          % the controllers know what's up
          options_hand.weld_to_link = 7;
          obj = obj.addRobotFromURDF(getFullPathFromRelativePath('../Atlas/urdf/robotiq_box.urdf'), [0.1; 0.0; 0.0], [pi; 0; pi/2], options_hand);
        else
          error('unsupported hand type');
        end
      end
    end
    
    function obj = compile(obj)
      obj = compile@TimeSteppingRigidBodyManipulator(obj);
      
      if (obj.initialized)
        % Sanity check if we have hands.
        if (~isa(obj.manip.getStateFrame().getFrameByNum(1), 'MultiCoordinateFrame'))
          obj.hands = 0;
        end
        if (obj.hands > 0)
          arm_state_frame = getStateFrame(obj);
          arm_state_frame = replaceFrameNum(arm_state_frame,1,IRB140State(obj));
          % Sub in handstates for each hand
          % TODO: by name?
          for i=2:obj.getStateFrame().getNumFrames
            arm_state_frame = replaceFrameNum(arm_state_frame,i,HandState(obj,i,'HandState'));
          end
        else
          arm_state_frame = IRB140State(obj);
        end
        tsmanip_state_frame = obj.getStateFrame();
        if tsmanip_state_frame.dim>arm_state_frame.dim
          id = findSubFrameEquivalentModuloTransforms(tsmanip_state_frame,arm_state_frame);
          tsmanip_state_frame.frame{id} = arm_state_frame;
          state_frame = tsmanip_state_frame;
        else
          state_frame = arm_state_frame;
        end
        obj.manip = obj.manip.setStateFrame(arm_state_frame);
        obj.manip = obj.manip.setOutputFrame(arm_state_frame);
        obj = obj.setStateFrame(state_frame);
        obj = obj.setOutputFrame(state_frame);
        
        if (obj.hands > 0)
          input_frame = getInputFrame(obj);
          input_frame  = replaceFrameNum(input_frame,1,IRB140Input(obj));
          % Sub in handstates for each hand
          % TODO: by name?
          for i=2:obj.getInputFrame().getNumFrames
            input_frame = replaceFrameNum(input_frame,i,HandInput(obj,i,'HandInput'));
          end
        else
          input_frame = IRB140Input(obj);
        end
        obj = obj.setInputFrame(input_frame);
        obj.manip = obj.manip.setInputFrame(input_frame);
      end
    end
  end
  properties (SetAccess = protected, GetAccess = public)
    hands = 0; % 0, none; 1, Robotiq
    initialized = 0;
  end
end
