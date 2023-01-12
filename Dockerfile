
# docker build -t <image name > .

FROM osrf/ros:kinetic-desktop-full

RUN echo "CREATING default workspace at ~/ws"

RUN mkdir -p ~/ws/src

RUN echo "INSTALLING dependencies"

RUN sudo apt-get update
RUN sudo apt-get install -y libpcap-dev wget
RUN sudo apt-get install -y ros-$ROS_DISTRO-joint-state-controller
RUN sudo apt-get install -y ros-$ROS_DISTRO-gazebo-ros-pkgs 
RUN sudo apt-get install -y ros-$ROS_DISTRO-gazebo-ros-control
RUN sudo apt-get install -y ros-$ROS_DISTRO-moveit
RUN sudo apt-get install -y gazebo7 ros-$ROS_DISTRO-qt-build ros-$ROS_DISTRO-gazebo-ros-control ros-$ROS_DISTRO-gazebo-ros-pkgs ros-$ROS_DISTRO-ros-control ros-$ROS_DISTRO-control-toolbox ros-$ROS_DISTRO-realtime-tools ros-$ROS_DISTRO-ros-controllers ros-$ROS_DISTRO-xacro python-wstool ros-$ROS_DISTRO-tf-conversions ros-$ROS_DISTRO-kdl-parser
RUN sudo apt install -y ros-$ROS_DISTRO-move-basic

RUN echo "ADDING baxter simulator and gazebo model"

RUN wstool init ~/ws/src
RUN wget https://bitbucket.org/DataspeedInc/mobility_base_ros/raw/master/mobility_base.rosinstall -O /tmp/mobility_base.rosinstall
RUN wget https://bitbucket.org/DataspeedInc/mobility_base_simulator/raw/master/mobility_base_simulator.rosinstall -O /tmp/mobility_base_simulator.rosinstall

RUN wstool merge -t ~/ws/src /tmp/mobility_base.rosinstall
RUN wstool merge -t ~/ws/src /tmp/mobility_base_simulator.rosinstall
RUN wstool merge -t ~/ws/src https://raw.githubusercontent.com/RethinkRobotics/baxter_simulator/kinetic-devel/baxter_simulator.rosinstall
RUN wstool update -t ~/ws/src

RUN rosdep update && rosdep install -y --from-paths ~/ws/src --ignore-src -r


RUN echo "ADDING setup.bash source for ROS and default workspace"

RUN /bin/bash -c '. /opt/ros/$ROS_DISTRO/setup.bash; cd ~/ws/; catkin_make'


RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
RUN echo "source ~/ws/devel/setup.bash" >> ~/.bashrc

RUN echo "ADDING ground and sun models for Gazebo 7"

RUN mkdir -p ~/.gazebo/
RUN cd ~/.gazebo/ && git clone https://github.com/mohammadasim98/models.git

RUN echo "INSTALLING vscode"

RUN sudo apt-get -y install wget
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
RUN sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
RUN sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
RUN rm -f packages.microsoft.gpg
RUN sudo apt install -y apt-transport-https
RUN sudo apt update
RUN sudo apt install -y code



RUN echo "ALL Done"
