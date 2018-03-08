1. Two Sum

Given an array of integers, return indices of the two numbers such that they add up to a specific target.

You may assume that each input would have exactly one solution, and you may not use the same element twice.

Example:

Given nums = [2, 7, 11, 15], target = 9,

Because nums[0] + nums[1] = 2 + 7 = 9,
return [0, 1].

public int[] twoSum(int[] nums, int target) {
	int[] result = new int[2];
	Map<Integer, Integer> map = new HashMap<Integer, Integer>();
	for (int i = 0; i < nums.length; i++) {
		//找到另一个目标值
		if (map.containsKey(target - nums[i])) {
			//取下标
			result[0] = i;
			result[1] = map.get(target - nums[i]);
			break;
		}
		map.put(nums[i], i);
	}
	return result;
}

======================================================

2. Add Two Numbers

You are given two non-empty linked lists representing two non-negative integers. The digits are stored in reverse order and each of their nodes contain a single digit. Add the two numbers and return it as a linked list.

You may assume the two numbers do not contain any leading zero, except the number 0 itself.

Example

Input: (2 -> 4 -> 3) + (5 -> 6 -> 4)
Output: 7 -> 0 -> 8
Explanation: 342 + 465 = 807.


public class Solution {
	public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
		ListNode dunmy = new ListNode(-1);
		ListNode cur = dunmy;
		int extra = 0;
		//注意进位时循环
		while (l1 != null || l2 != null || extra > 0) {
			int sum = (l1 == null ? 0 : l1.val) + (l2 == null ? 0 : l2.val) + extra;
			extra = sum / 10;
			sum = sum % 10;
			//注意l1 l2为空的情况
			l1 = l1 == null ? null : l1.next;
			l2 = l2 == null ? null : l2.next;
			ListNode tmp = new ListNode(sum);
			cur.next = tmp;
			cur = tmp;
		}
		return dunmy.next;
	}
}

class ListNode {
	int val;
	ListNode next;
	ListNode(int x) { val = x; }
}