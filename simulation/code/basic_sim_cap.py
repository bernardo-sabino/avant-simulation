import cv2
import rclpy
from cv_bridge import CvBridge, CvBridgeError
from rclpy.node import Node
from sensor_msgs.msg import Image
class ImageViewer(Node):
	def __init__(self):
		super().__init__("basic_sim_cap")
		self.bridge = CvBridge()
		self.subscription = self.create_subscription(
			Image,
			"/camera/camera/image_raw",
			self.image_callback,
			10,
		)
		self.window_name = "Simulated Camera"
		cv2.namedWindow(self.window_name, cv2.WINDOW_NORMAL)

	def image_callback(self, message):
		try:
			frame = self.bridge.imgmsg_to_cv2(message, desired_encoding="bgr8")
		except CvBridgeError as error:
			self.get_logger().error(f"Image conversion failed: {error}")
			return

		cv2.imshow(self.window_name, frame)

	def close(self):
		cv2.destroyAllWindows()


def main():
	rclpy.init()
	node = ImageViewer()

	try:
		while rclpy.ok():
			rclpy.spin_once(node, timeout_sec=0.01)
			key = cv2.waitKey(1) & 0xFF
			if key in (ord("q"), 27):
				break
	except KeyboardInterrupt:
		pass
	finally:
		node.close()
		node.destroy_node()
		rclpy.shutdown()

if __name__ == "__main__":
	main()
