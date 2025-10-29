#include <linux/module.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/gpio/consumer.h>


#define OUT 20
#define IN 12

#define IO_OFFSET 571 // global offset for raspberry pi 5

static int major;
//static char text[64];
static char c = 'a';
static struct gpio_desc *led, *in;

/*
 * user_count: requesting size to read from the user.
 * offset: the offset for internal data where it is pointing to.
 */
static ssize_t my_read(struct file *filp, char __user *user_buf, size_t user_count, loff_t *offset)
{
  size_t data_size = 1;
  size_t not_copied;
  size_t bytes_available = data_size - *offset;
  size_t bytes_to_read = min(user_count, bytes_available);
  int value;

  if (bytes_to_read == 0)
    return 0;
  value = gpiod_get_value(in);
  if (value)
    c = '1';
  else
    c = '0';

  /*
   * bytes_to_read: the number to copy to user.
   * not_copied: the number that is not copied. If it's same as bytes_to_read, it is an error.
   *             if 0, all the data has been copied to user.
   */
	not_copied = copy_to_user(user_buf, &c, bytes_to_read);
  if (not_copied) {
    size_t partial_copied = bytes_to_read - not_copied;
    if (partial_copied == 0)
        return -EFAULT;
    *offset += partial_copied;
    return partial_copied;
  }
  // increase offset by the number it has actually copied.
  *offset += bytes_to_read;
  pr_info("read: %zu, %lld", user_count, *offset);

  // bytes actually copied to user.
  return bytes_to_read;
}

/*
 * user_count: requesting size to write from the user to the device.
 * offset: the offset for internal data where it is pointing to.
 */

static ssize_t my_write(struct file *filp, const char __user *user_buf, size_t user_count, loff_t *offset)
{
  size_t data_size = 1;
  size_t not_copied;
  size_t bytes_available = data_size - *offset;
  size_t bytes_to_write = min(user_count, bytes_available);

  if (bytes_to_write == 0)
    return 0;

  /*
   * bytes_to_write: the number to copy from user to the device.
   * not_copied: the number that is not copied. If it's same as bytes_to_read, it is an error.
   *             if 0, all the data has been copied to the device.
   */
	not_copied = copy_from_user(&c, user_buf, bytes_to_write);
  if (not_copied) {
    size_t copied = bytes_to_write - not_copied;
    if (copied == 0)
        return -EFAULT;
    return copied;
  }
  *offset += bytes_to_write;

  if (c == '1')
    gpiod_set_value(led, 1);
  else
    gpiod_set_value(led, 0);

  pr_info("write: %zu, %lld", user_count, *offset);

  // bytes actually copied to the device.
	return bytes_to_write;
}

static struct file_operations fops = {
	.read = my_read,
	.write = my_write
};

static int __init my_init(void)
{
  int status;
	major = register_chrdev(0, "hello_cdev", &fops);
	if (major < 0) {
		pr_err("hello_cdev - Error registering chrdev\n");
		return major;
	}
	printk("hello_cdev - Major Device Number: %d\n", major);

  led = gpio_to_desc(IO_OFFSET + OUT);
  if (!led) {
    printk("gpioctrl - Error getting pin %d\n", OUT);
    return -ENODEV;
  }

  in = gpio_to_desc(IO_OFFSET + IN);
  if (!in) {
    printk("gpioctrl - Error getting pin %d\n", IN);
    return -ENODEV;
  }

  status = gpiod_direction_output(led, 0);
  if (status) {
    printk("gpioctrl - Error setting pin %d to output\n", OUT);
    return status;
  }

  status = gpiod_direction_input(in);
  if (status) {
    printk("gpioctrl - Error setting pin %d to input\n", IN);
    return status;
  }
	return 0;

}

static void __exit my_exit(void)
{
	unregister_chrdev(major, "hello_cdev");
}

module_init(my_init);
module_exit(my_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("-");
MODULE_DESCRIPTION("-");
